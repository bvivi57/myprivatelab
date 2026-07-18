variable "xoa_insecure" {
  description = "Désactive la vérification TLS vers Xen Orchestra (certificat auto-signé non approuvé par le poste). La variable d'environnement XOA_INSECURE n'est pas prise en compte de façon fiable par le provider 0.39.x, d'où ce passage explicite."
  type        = bool
  default     = true
}

variable "template_name" {
  description = "Nom du template XCP-ng à cloner (construit en phase 1 Packer). Défaut pour tous les pools, surchargeable par pool."
  type        = string
  default     = "prdtplroc501"
}

variable "pools" {
  description = <<-EOT
    Réseaux et template PAR POOL XCP-ng (clé = name_label exact du pool).
    Ne déclarer QUE les pools réellement utilisés (témoin : un seul pool).
      lan_network_name : name_label du réseau LAN sur ce pool
      dmz_network_name : name_label du réseau DMZ sur ce pool (requis si nœuds zone=dmz)
      template_name    : (optionnel) surcharge du template sur ce pool, sinon var.template_name
    Le template doit EXISTER sur chaque pool listé (copie cross-pool dans XO).
  EOT
  type = map(object({
    lan_network_name = string
    dmz_network_name = optional(string, "")
    template_name    = optional(string)
  }))
}

variable "hosts" {
  description = <<-EOT
    Hôtes XCP-ng utilisables (clé = name_label exact de l'hôte).
    Stockage LOCAL par hôte → le SR appartient à l'hôte ; choisir l'hôte fixe le SR.
      pool    : clé dans var.pools à laquelle l'hôte appartient
      sr_name : name_label du SR (local) où poser les disques des VMs de cet hôte
  EOT
  type = map(object({
    pool    = string
    sr_name = string
  }))

  validation {
    condition     = alltrue([for h in var.hosts : contains(keys(var.pools), h.pool)])
    error_message = "Chaque hosts[*].pool doit correspondre à une clé déclarée dans var.pools."
  }
}

variable "network_interface" {
  description = "Nom de l'interface réseau dans la VM, côté cloud-init (network-config). Sur le template Rocky 10 : enX0."
  type        = string
  default     = "enX0"
}

variable "dns_servers" {
  description = "Serveurs DNS internes (zone coolcorp.priv)."
  type        = list(string)
  default     = ["192.168.10.30"]
}

variable "search_domain" {
  description = "Domaine de recherche DNS et suffixe FQDN des nœuds."
  type        = string
  default     = "coolcorp.priv"
}

variable "zones" {
  description = "Paramètres réseau par zone (passerelle + préfixe CIDR)."
  type = map(object({
    gateway = string
    prefix  = number
  }))
  default = {
    lan = { gateway = "192.168.10.253", prefix = 24 }
    dmz = { gateway = "192.168.5.253", prefix = 24 }
  }
}

variable "nodes" {
  description = <<-EOT
    Carte des VMs à déployer (clé = hostname court).
    PREMIER ESSAI : ne mettre qu'UNE entrée (VM témoin). Étendre ensuite aux 11 nœuds.
      role          : control-plane | worker | haproxy
      ansible_group : k8s_controlplane_lan | k8s_workers_lan | k8s_workers_web | nlb_haproxy_lan | nlb_haproxy_web
      zone          : lan | dmz (doit être cohérente avec le suffixe du groupe)
      host          : clé dans var.hosts (détermine pool, SR et placement)
      ip            : IP statique (sans préfixe)
      traefik       : (optionnel, défaut false) le nœud portera une instance Traefik ;
                      l'ajoute au groupe applicatif k8s_traefik_lan ou k8s_traefik_web
                      selon sa zone (workers uniquement)
  EOT
  type = map(object({
    role          = string
    ansible_group = string
    zone          = string
    host          = string
    ip            = string
    cpus          = number
    memory_gb     = number
    disk_gb       = number
    traefik       = optional(bool, false)
  }))

  validation {
    condition     = alltrue([for n in var.nodes : contains(["lan", "dmz"], n.zone)])
    error_message = "Chaque nœud doit avoir zone = \"lan\" ou \"dmz\"."
  }

  validation {
    condition = alltrue([for n in var.nodes : contains(
      ["k8s_controlplane_lan", "k8s_workers_lan", "k8s_workers_web", "nlb_haproxy_lan", "nlb_haproxy_web"],
    n.ansible_group)])
    error_message = "ansible_group invalide (valeurs attendues : k8s_controlplane_lan, k8s_workers_lan, k8s_workers_web, nlb_haproxy_lan, nlb_haproxy_web)."
  }

  validation {
    condition     = alltrue([for n in var.nodes : (n.zone == "dmz") == contains(["k8s_workers_web", "nlb_haproxy_web"], n.ansible_group)])
    error_message = "Incohérence zone/groupe : les groupes *_web exigent zone = \"dmz\", les autres zone = \"lan\" (les groupes transverses sys_net_lan/sys_net_web sont dérivés des groupes de rôle)."
  }

  validation {
    condition     = alltrue([for n in var.nodes : !n.traefik || contains(["k8s_workers_lan", "k8s_workers_web"], n.ansible_group)])
    error_message = "traefik = true n'est permis que sur les workers (k8s_workers_lan ou k8s_workers_web)."
  }

  validation {
    condition     = alltrue([for n in var.nodes : contains(keys(var.hosts), n.host)])
    error_message = "Chaque node.host doit correspondre à une clé déclarée dans var.hosts."
  }

  validation {
    condition     = alltrue([for n in var.nodes : n.zone != "dmz" || try(var.pools[var.hosts[n.host].pool].dmz_network_name, "") != ""])
    error_message = "Un nœud zone=dmz exige dmz_network_name défini sur le pool de son hôte."
  }
}
