# ============================================================================
# example.pkrvars.hcl — MODÈLE de variables (versionné, valeurs fictives)
# Copier en « xkub.auto.pkrvars.hcl » (ignoré par git) puis renseigner.
#   PowerShell : Copy-Item example.pkrvars.hcl xkub.auto.pkrvars.hcl
# Le mot de passe XCP-ng NE figure PAS ici : il passe par la variable
# d'environnement PKR_VAR_remote_password.
# ============================================================================

# --- Hôte XCP-ng ---
remote_host     = "192.168.10.10" # adresse XAPI du pool master XCP-ng
remote_username = "root"

# --- Emplacements XCP-ng (noms tels qu'affichés dans Xen Orchestra) ---
sr_name       = "Local storage"                            # SR du disque/template
sr_iso_name   = "ISOs"                                     # SR de type ISO
network_names = ["Pool-wide network associated with eth0"] # réseau LAN (DHCP + Internet)

# --- Clé privée ansible-windows (sur le poste W11, hors dépôt) ---
ssh_private_key_path = "C:/Users/vburgun/.ssh/ansible-windows"

# --- (Optionnel) surcharges ---
# vm_name   = "prdtplroc501"
# disk_size = 20480
