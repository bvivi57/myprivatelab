# ============================================================================
# variables.pkr.hcl — Template Rocky Linux 10 (xkub.coolcorp.priv)
# Toutes les variables du build. Les secrets ne portent PAS de valeur ici :
# ils sont fournis par variables d'environnement PKR_VAR_* (cf. CONVENTIONS.md).
# ============================================================================

# --- Connexion à l'hôte XCP-ng (API XAPI) -----------------------------------
variable "remote_host" {
  type        = string
  description = "Adresse de l'hôte XCP-ng (pool master) sur lequel Packer construit la VM."
}

variable "remote_username" {
  type        = string
  default     = "root"
  description = "Compte XAPI de l'hôte XCP-ng."
}

variable "remote_password" {
  type        = string
  sensitive   = true
  description = "Mot de passe XAPI. À fournir via PKR_VAR_remote_password (jamais en clair dans un fichier versionné)."
}

variable "remote_ssh_port" {
  type        = number
  default     = 22
  description = "Port SSH de l'hôte XCP-ng (utilisé par le plugin pour piloter le build)."
}

# --- Emplacements XCP-ng ----------------------------------------------------
variable "sr_name" {
  type        = string
  description = "Nom du Storage Repository où créer le disque de la VM puis le template."
}

variable "sr_iso_name" {
  type        = string
  description = "Nom du SR de type ISO où Packer téléverse l'ISO Rocky Linux."
}

variable "network_names" {
  type        = list(string)
  description = "Réseau(x) XCP-ng à attacher à la VM de build (DHCP + accès aux dépôts requis)."
}

# --- Source ISO Rocky Linux 10 ----------------------------------------------
variable "iso_url" {
  type        = string
  default     = "https://download.rockylinux.org/pub/rocky/10/isos/x86_64/Rocky-10.2-x86_64-minimal.iso"
  description = "URL de l'ISO Rocky Linux 10 minimal."
}

variable "iso_checksum" {
  type        = string
  default     = "sha256:aac6ac3ce781b91a91ce78463405f66c611a5dca4b3840c79e5e01d97302f6c8"
  description = "Empreinte de l'ISO (Rocky-10.2-x86_64-minimal.iso)."
}

# --- Définition de la VM de build / template --------------------------------
variable "vm_name" {
  type        = string
  default     = "prdtplroc501"
  description = "Nom du template produit (convention de nommage prd du projet)."
}

variable "vm_description" {
  type        = string
  default     = "Template generique Rocky Linux 10 - xkub.coolcorp.priv (Packer)"
  description = "Description du template dans XO."
}

variable "vcpus" {
  type        = number
  default     = 2
  description = "vCPU de la VM de build (le dimensionnement final est fait par Terraform au clone)."
}

variable "vm_memory" {
  type        = number
  default     = 2048
  description = "RAM (Mo) de la VM de build."
}

variable "disk_size" {
  type        = number
  default     = 20480
  description = "Taille (Mo) du disque du template. Étendu par rôle au clone (cloud-init growpart)."
}

# --- Connexion SSH post-install ---------------------------------------------
variable "ssh_username" {
  type        = string
  default     = "ansible-windows"
  description = "Compte utilisé par Packer pour provisionner la VM (créé par le kickstart)."
}

variable "ssh_private_key_path" {
  type        = string
  description = "Chemin LOCAL (poste W11) vers la clé PRIVÉE ansible-windows. Hors dépôt."
}

# --- Timings -----------------------------------------------------------------
variable "boot_wait" {
  type        = string
  default     = "10s"
  description = "Délai avant l'envoi du boot_command (laisser le menu d'amorçage s'afficher)."
}

variable "install_timeout" {
  type        = string
  default     = "60m"
  description = "Durée maximale de l'installation Anaconda."
}
