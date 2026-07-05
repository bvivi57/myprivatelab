# ============================================================================
# rocky10-base.pkr.hcl — Source + build du template Rocky Linux 10
# Plugin : vatesfr/xenserver (builder xenserver-iso). Cf. cookbook 01.
# ============================================================================

packer {
  required_plugins {
    xenserver = {
      version = ">= 0.9.0"
      source  = "github.com/vatesfr/xenserver"
    }
  }
}

source "xenserver-iso" "rocky10" {
  # --- Connexion à l'hôte XCP-ng (XAPI) ---
  remote_host     = var.remote_host
  remote_username = var.remote_username
  remote_password = var.remote_password
  remote_ssh_port = var.remote_ssh_port

  # --- Emplacements XCP-ng ---
  sr_name       = var.sr_name
  sr_iso_name   = var.sr_iso_name
  network_names = var.network_names

  # --- Source ISO ---
  iso_url      = var.iso_url
  iso_checksum = var.iso_checksum

  # --- VM de build / futur template ---
  vm_name         = var.vm_name
  vm_description  = var.vm_description
  vcpus_max       = var.vcpus
  vcpus_atstartup = var.vcpus
  vm_memory       = var.vm_memory
  disk_size       = var.disk_size
  firmware        = "bios"

  # --- Kickstart servi par le serveur HTTP intégré de Packer ---
  # Le dossier http/ contient ks.cfg ET ansible-windows.pub (clé publique servie
  # au kickstart, qui la récupère par curl — pas de mot de passe nécessaire).
  http_directory  = "http"
  boot_wait       = var.boot_wait
  install_timeout = var.install_timeout
  # Détection d'IP par phone-home HTTP : la VM de build (DHCP) télécharge le kickstart
  # depuis le serveur HTTP de Packer, qui capture l'IP source. Le plugin vatesfr/xenserver
  # n'expose pas de ssh_host fixe ; "tools" est exclu (guest tools installés seulement au
  # provisioning). L'IP reste la même avant/après reboot (bail DHCP stable sur la MAC).
  ip_getter = "http"
  # PIÈGE EL10 : Rocky Linux 10 amorce l'ISO avec GRUB2 (et non isolinux), même en
  # BIOS. Les touches d'édition diffèrent : 'e' pour éditer l'entrée (pas <tab>),
  # on complète la ligne 'linux ...', puis Ctrl-X pour démarrer.
  boot_command = [
    "<wait5>",
    "<up><wait>",        # sélectionner « Install Rocky Linux Minimal 10.2 »
    "e<wait>",           # éditer l'entrée GRUB2
    "<down><down><end>", # fin de la ligne « linux /images/pxeboot/vmlinuz ... »
    " inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg",
    "<wait><leftCtrlOn>x<leftCtrlOff>", # démarrer
  ]

  # --- Connexion SSH post-install (par clé ansible-windows) ---
  ssh_username     = var.ssh_username
  ssh_key_path     = var.ssh_private_key_path
  ssh_wait_timeout = "60m"

  # --- Finalisation : convertir la VM en template ET la conserver sur l'hôte ---
  # keep_vm = "always" : le template reste dans XCP-ng à la fin du build (objectif
  # phase 1 = template réutilisable dans XO, pas seulement un fichier XVA local).
  # Avec "never" (défaut du plugin), la VM était convertie en template, exportée en
  # XVA dans output-rocky10/, puis DÉTRUITE de l'hôte → invisible dans XO.
  skip_set_template = false
  keep_vm           = "always"
}

build {
  name    = "rocky10-base"
  sources = ["source.xenserver-iso.rocky10"]

  # Hostname OS aligné sur le nom de la VM/template (source unique = var.vm_name).
  # Il sera de toute façon redéfini par clone via cloud-init (Terraform, phase 2) ;
  # ici c'est surtout une question de cohérence VM XCP-ng <-> hostname OS.
  provisioner "shell" {
    inline = ["sudo hostnamectl set-hostname ${var.vm_name}"]
  }

  # ansible-windows dispose de sudo NOPASSWD (posé par le kickstart).
  provisioner "shell" {
    execute_command = "sudo -E bash '{{ .Path }}'"
    scripts = [
      "scripts/10-guest-tools.sh",
      "scripts/20-cloud-init.sh",
      "scripts/90-cleanup.sh",
    ]
  }
}
