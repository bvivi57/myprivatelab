# ---------------------------------------------------------------------------
# Datasources Xen Orchestra. Le provider parle à un seul XO qui voit les 3
# pools ; on désambiguïse via pool_id (template répliqué = même name_label
# sur chaque pool). Réseaux + template = par POOL ; SR = par HÔTE (stockage local).
# ---------------------------------------------------------------------------

data "xenorchestra_pool" "this" {
  for_each   = var.pools
  name_label = each.key
}

data "xenorchestra_template" "this" {
  for_each   = var.pools
  name_label = coalesce(each.value.template_name, var.template_name)
  pool_id    = data.xenorchestra_pool.this[each.key].id
}

data "xenorchestra_network" "lan" {
  for_each   = var.pools
  name_label = each.value.lan_network_name
  pool_id    = data.xenorchestra_pool.this[each.key].id
}

data "xenorchestra_network" "dmz" {
  for_each   = { for k, v in var.pools : k => v if v.dmz_network_name != "" }
  name_label = each.value.dmz_network_name
  pool_id    = data.xenorchestra_pool.this[each.key].id
}

data "xenorchestra_sr" "this" {
  for_each   = var.hosts
  name_label = each.value.sr_name
  pool_id    = data.xenorchestra_pool.this[each.value.pool].id
}

# Hôtes XCP-ng réellement utilisés par des nœuds → ID pour figer le placement.
data "xenorchestra_host" "this" {
  for_each   = local.used_hosts
  name_label = each.value
}

# ---------------------------------------------------------------------------
# Déploiement des VMs (un module générique, piloté par la map var.nodes)
# ---------------------------------------------------------------------------

module "node" {
  source   = "./modules/k8s-node"
  for_each = var.nodes

  hostname    = each.key
  template_id = data.xenorchestra_template.this[var.hosts[each.value.host].pool].id
  sr_id       = data.xenorchestra_sr.this[each.value.host].id
  network_id  = each.value.zone == "dmz" ? data.xenorchestra_network.dmz[var.hosts[each.value.host].pool].id : data.xenorchestra_network.lan[var.hosts[each.value.host].pool].id

  cpus      = each.value.cpus
  memory_gb = each.value.memory_gb
  disk_gb   = each.value.disk_gb
  tags      = local.node_tags[each.key]

  interface     = var.network_interface
  ip            = each.value.ip
  prefix        = var.zones[each.value.zone].prefix
  gateway       = var.zones[each.value.zone].gateway
  dns_servers   = var.dns_servers
  search_domain = var.search_domain

  affinity_host_id = data.xenorchestra_host.this[each.value.host].id
}
