#######################Variables vsphere

variable "vsphere_user" {
  default = "$compte_de_service_pour_accéder_au_vcenter$"
}

variable "vsphere_password" {
    type = string
    sensitive = true
}

variable "vsphere_server" {
  default = "$url_vcenter$"
}

variable "vsphere_datacenter" {
  default = "$datacenter_vsphere$"
}

variable "vsphere_cluster" {
  default = "$cluster_vpshere$"
}

variable "vsphere_template" {
  default = "$template_de_vm_à_utiliser$"
}



################################### Variables Network

variable "vlan_lan" {
  default = "$nom_du_port_group$"
}


variable "gateway_lan" {
  default = "$ip_de_la_gateway_de_la_vm$"
}


variable "default_dns" {
  default = "$ip_du_dns_vm$"
}

variable "default_dns_domain" {
  default = "$domaine_dns$"
}


#################################### Variables VMs

####Detail VM

variable "vm_01_name" {
  default = "$nom_de_la_vm$"
}

variable "vm_01_dts" {
  default = "$datastore_ou_stocker_la_vm$"
}

variable "vm_01_cpu_number" {
  default = "2"
}

variable "vm_01_memory_size" {
  default = "2048"
}

variable "vm_01_ip_address" {
  default = "$ip_de_la_vm$"
}

variable "vm_01_ip_netmask" {
  default = "$mask_ip_de_la_vm$"
}

