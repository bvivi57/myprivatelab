#Caterogie Applicatif
resource "vsphere_tag_category" "primary_category" {
  name        = "${var.tag_primary_category}"
  cardinality = "SINGLE"
  description = "Application sur la VM"

  associable_types = [
    "VirtualMachine",
    "Datastore",
  ]
}

resource "vsphere_tag" "tag_apps" {
  name        = "${var.tag_apps}"
  category_id = "${vsphere_tag_category.primary_category.id}"
  description = "Application de la VM"
}

#Catagorgie role
resource "vsphere_tag_category" "role_category" {
  name        = "${var.tag_role_category}"
  cardinality = "SINGLE"
  description = "Role de la VM"

  associable_types = [
    "VirtualMachine",
    "Datastore",
  ]
}

resource "vsphere_tag" "tag_apps_master" {
  name        = "${var.tag_role_master}"
  category_id = "${vsphere_tag_category.role_category.id}"
  description = "Master K8S"
}

resource "vsphere_tag" "tag_apps_worker" {
  name        = "${var.tag_role_worker}"
  category_id = "${vsphere_tag_category.role_category.id}"
  description = "Worker K8S"
}

resource "vsphere_tag" "tag_apps_haproxy" {
  name        = "${var.tag_role_haproxy}"
  category_id = "${vsphere_tag_category.role_category.id}"
  description = "HAproxy"
}

#Categorie Network
resource "vsphere_tag_category" "role_category_network" {
  name        = "${var.tag_network_category}"
  cardinality = "SINGLE"
  description = "Zone réseau de la VM"

  associable_types = [
    "VirtualMachine",
    "Datastore",
  ]
}

resource "vsphere_tag" "tag_net_lan" {
  name        = "${var.tag_network_lan}"
  category_id = "${vsphere_tag_category.role_category_network.id}"
  description = "Reseau LAN"
}

resource "vsphere_tag" "tag_net_web" {
  name        = "${var.tag_network_web}"
  category_id = "${vsphere_tag_category.role_category_network.id}"
  description = "DMZ WEB"
}