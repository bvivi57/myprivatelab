#######################Variables vsphere

variable "vsphere_user" {
  default = "$user_pour_acces_vcenter$"
}

variable "vsphere_password" {
    type = string
    sensitive = true
}

variable "vsphere_server" {
  default = "vcenter.coolcorp.priv"
}

variable "vsphere_datacenter" {
  default = "Paris"
}

variable "vsphere_cluster" {
  default = "$nom_cluster_vpshere$"
}

variable "vsphere_template" {
  default = "$nom_template_vpshere$"
}

variable "tag_primary_category" {
  default = "$nom_tag_cat_apps"
}

variable "tag_apps" {
  default = "$nom_tag_apps"
}

variable "tag_role_category" {
  default = "$nom_tag_cat_role"
}

variable "tag_role_master" {
  default = "$nom_tag_apps_master"
}

variable "tag_role_worker" {
  default = "$nom_tag_apps_worker"
}

variable "tag_role_haproxy" {
  default = "$nom_tag_apps_haproxy"
}

variable "tag_network_category" {
  default = "$nom_tag_cat_network"
}

variable "tag_network_lan" {
  default = "$nom_tag_lan"
}

variable "tag_network_web" {
  default = "$nom_tag_lan"
}

################################### Variables Network

variable "vlan_lan" {
  default = "$nom_vlan_interne$"
}

variable "vlan_dmz" {
  default = "$nom_vlan_web$"
}

variable "gateway_lan" {
  default = "$IP_gateway_lan$"
}

variable "gateway_dmz" {
  default = "$IP_gateway_dmz$"
}

variable "default_dns" {
  default = "$IP_dns$"
}

variable "default_dns_domain" {
  default = "$nom_dns_domaine$"
}


#################################### Variables serveur

####Detail Master 1

variable "master_01_name" {
  default = "$nom_premier_master$"
}

variable "master_01_dts" {
  default =  "$nom_datastore_premier_master$"
}

variable "master_01_cpu_number" {
  default = "$nombre_vcpu_master$"
}

variable "master_01_memory_size" {
  default = "$quantité_ram_master$"
}

variable "master_01_ip_address" {
  default = "$IP_premier_master$"
}

variable "master_01_ip_netmask" {
  default = "$IP_mask_premier_master$"
}


####Detail Master 2

variable "master_02_name" {
  default = "$nom_second_master$"
}

variable "master_02_dts" {
  default = "$nom_datastore_second_master$"
}

variable "master_02_cpu_number" {
  default =  "$nombre_vcpu_master$"
}

variable "master_02_memory_size" {
  default = "$quantité_ram_master$"
}

variable "master_02_ip_address" {
  default = "$IP_second_master$"
}

variable "master_02_ip_netmask" {
  default = "$IP_mask_second_master$"
}

####Detail Master 3

variable "master_03_name" {
  default = "$nom_troisieme_master$"
}

variable "master_03_dts" {
  default = "$nom_datastore_troisieme_master$"
}

variable "master_03_cpu_number" {
  default = "$nombre_vcpu_master$"
}

variable "master_03_memory_size" {
  default = "$quantité_ram_master$"
}

variable "master_03_ip_address" {
  default = "$IP_troisieme_master$"
}

variable "master_03_ip_netmask" {
  default = "$IP_mask_troisieme_master$"
}

####Detail Worker 1 (LAN)

variable "worker_lan_01_name" {
  default = "$nom_premier_worker_name$"
}

variable "worker_lan_01_dts" {
  default = "$nom_datastore_premier_worker_name$"
}

variable "worker_lan_01_cpu_number" {
  default = "$nombre_vcpu_worker$"
}

variable "worker_lan_01_memory_size" {
  default = "$quantité_ram_worker$"
}

variable "worker_lan_01_ip_address" {
  default = "$IP_premier_worker$"
}

variable "worker_lan_01_ip_netmask" {
  default = "$IP_mask_premier_worker$"
}

####Detail Worker 2 (LAN)

variable "worker_lan_02_name" {
  default = "$nom_premier_second_name$"
}

variable "worker_lan_02_dts" {
  default = "$nom_datastore_second_worker_name$"
}

variable "worker_lan_02_cpu_number" {
  default = "$nombre_vcpu_worker$"
}

variable "worker_lan_02_memory_size" {
  default = "$quantité_ram_worker$"
}

variable "worker_lan_02_ip_address" {
  default = "$IP_second_worker$"
}

variable "worker_lan_02_ip_netmask" {
  default = "$IP_mask_second_worker$"
}

####Detail Worker 1 (DMZ)

variable "worker_dmz_01_name" {
  default = "$nom_premier_worker_name_dmz$"
}

variable "worker_dmz_01_dts" {
  default = "$nom_datastore_premier_worker_name_dmz$"
}

variable "worker_dmz_01_cpu_number" {
  default = "$nombre_vcpu_worker$"
}

variable "worker_dmz_01_memory_size" {
  default = "$quantité_ram_worker$"
}

variable "worker_dmz_01_ip_address" {
  default =  "$IP_premier_worker_dmz$"
}

variable "worker_dmz_01_ip_netmask" {
  default = "$IP_mask_premier_worker_dmz$"
}

####Detail Worker 2 (DMZ)

variable "worker_dmz_02_name" {
  default = "$nom_second_worker_name_dmz$"
}

variable "worker_dmz_02_dts" {
  default = "$nom_datastore_second_worker_name_dmz$"
}

variable "worker_dmz_02_cpu_number" {
  default = "$nombre_vcpu_worker$"
}

variable "worker_dmz_02_memory_size" {
  default = "$quantité_ram_worker$"
}

variable "worker_dmz_02_ip_address" {
  default = "$IP_second_worker_dmz$"
}

variable "worker_dmz_02_ip_netmask" {
  default = "$IP_mask_second_worker_dmz$"
}

####Detail HA Proxy LAN
variable "haproxy_lan_01_name" {
  default = "$nom_ha_proxy_lan$"
}

variable "haproxy_lan_01_dts" {
  default = "$nom_ha_proxy_name_datastore_lan$"
}

variable "haproxy_lan_01_cpu_number" {
  default = "$nombre_vcpu_haproxy$"
}

variable "haproxy_lan_01_memory_size" {
  default = "$nombre_quantite_ram_haproxy$"
}

variable "haproxy_lan_01_ip_address" {
  default = "$IP_haproxy_lan$"
}

variable "haproxy_lan_01_ip_netmask" {
  default = "$IP_haproxy_netmask_lan$"
}

####Detail HA Proxy DMZ

variable "haproxy_dmz_01_name" {
  default = "$nom_ha_proxy_dmz$"
}

variable "haproxy_dmz_01_dts" {
  default = "$nom_ha_proxy_name_datastore_dmz$"
}

variable "haproxy_dmz_01_cpu_number" {
  default = "$nombre_vcpu_haproxy$"
}

variable "haproxy_dmz_01_memory_size" {
  default = "$nombre_quantite_ram_haproxy$"
}

variable "haproxy_dmz_01_ip_address" {
  default = "$IP_haproxy_dmz$"
}

variable "haproxy_dmz_01_ip_netmask" {
  default = "$IP_haproxy_netmask_dmz$
}