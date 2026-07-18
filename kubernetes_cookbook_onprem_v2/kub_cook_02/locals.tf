locals {
  # Hôtes XCP-ng distincts réellement utilisés par des nœuds.
  used_hosts = toset([for n in var.nodes : n.host])

  # ---- Construction de l'inventaire Ansible -------------------------------
  # Les hôtes ne sont déclarés QUE dans les groupes de rôle ; les groupes
  # transverses (clu_k8s_xkub, os_lin_r10, sys_net_lan, sys_net_web) les
  # référencent comme enfants. Avantage : le baremetal prdk8smin520, ajouté
  # à la main dans k8s_workers_lan + gpu, héritera automatiquement de tous
  # les groupes transverses.
  role_groups = [
    "k8s_controlplane_lan",
    "k8s_workers_lan",
    "k8s_workers_web",
    "nlb_haproxy_lan",
    "nlb_haproxy_web",
  ]

  # Répartition zone réseau -> groupes de rôle (gpu = baremetal, côté LAN).
  # La cohérence zone/groupe des nœuds est garantie par une validation
  # de var.nodes.
  lan_groups = ["k8s_controlplane_lan", "k8s_workers_lan", "nlb_haproxy_lan", "gpu"]
  web_groups = ["k8s_workers_web", "nlb_haproxy_web"]

  group_hosts = {
    for g in local.role_groups : g => {
      for name, n in var.nodes :
      "${name}.${var.search_domain}" => { ansible_host = n.ip }
      if n.ansible_group == g
    }
  }

  # Tags XO par nœud : miroir exact des groupes d'inventaire Ansible de la VM
  # (rôle + transverses + traefik éventuel). Exploitable dans XO pour la
  # recherche, les smart backups et les ACLs.
  node_tags = {
    for name, n in var.nodes : name => concat(
      [
        n.ansible_group,
        "clu_k8s_xkub",
        "os_lin_r10",
        n.zone == "dmz" ? "sys_net_web" : "sys_net_lan",
      ],
      n.traefik ? [n.zone == "dmz" ? "k8s_traefik_web" : "k8s_traefik_lan"] : [],
    )
  }

  # Groupes applicatifs Traefik : sous-ensemble des workers portant le flag
  # traefik dans var.nodes (une instance LAN, une instance WEB). Seuls groupes
  # à redéclarer des hôtes en plus des groupes de rôle — c'est voulu : le
  # périmètre Traefik est un choix par nœud, pas déductible d'un groupe.
  traefik_hosts = {
    for z, g in { lan = "k8s_traefik_lan", dmz = "k8s_traefik_web" } : g => {
      for name, n in var.nodes :
      "${name}.${var.search_domain}" => { ansible_host = n.ip }
      if n.traefik && n.zone == z
    }
  }

  inventory = {
    all = {
      vars = {
        ansible_user = "ansible-windows"
      }
      children = {
        # Groupe cluster : toutes les machines de la plateforme xkub.
        "clu_k8s_xkub" = {
          children = merge(
            { for g in local.role_groups : g => { hosts = local.group_hosts[g] } },
            { gpu = { hosts = {} } },
          )
        }
        # Groupes applicatifs Traefik (hôtes déclarés directement, cf. plus haut).
        "k8s_traefik_lan" = { hosts = local.traefik_hosts.k8s_traefik_lan }
        "k8s_traefik_web" = { hosts = local.traefik_hosts.k8s_traefik_web }
        # Groupes transverses : références (vides) vers les groupes de rôle.
        "os_lin_r10"  = { children = { for g in concat(local.role_groups, ["gpu"]) : g => {} } }
        "sys_net_lan" = { children = { for g in local.lan_groups : g => {} } }
        "sys_net_web" = { children = { for g in local.web_groups : g => {} } }
      }
    }
  }
}
