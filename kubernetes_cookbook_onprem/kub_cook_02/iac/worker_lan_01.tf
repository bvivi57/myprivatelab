
data "vsphere_datastore" "datastore_lan_worker_01" {
  name          = "${var.worker_lan_01_dts}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

resource "vsphere_virtual_machine" "vm_lan_worker_01" {
  name             = "${var.worker_lan_01_name}"
  resource_pool_id = "${data.vsphere_compute_cluster.cluster.resource_pool_id}"
  datastore_id     = "${data.vsphere_datastore.datastore_lan_worker_01.id}"

  num_cpus = "${var.worker_lan_01_cpu_number}"
  memory   = "${var.worker_lan_01_memory_size}"
  guest_id = "${data.vsphere_virtual_machine.template.guest_id}"
  tags = ["${vsphere_tag.tag_apps.id}","${vsphere_tag.tag_apps_worker.id}","${vsphere_tag.tag_net_lan.id}"]

  scsi_type = "${data.vsphere_virtual_machine.template.scsi_type}"

  network_interface {
    network_id   = "${data.vsphere_network.network_lan.id}"
    adapter_type = "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
  }

  disk {
    label            = "disk0"
    size             = "${data.vsphere_virtual_machine.template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
  }

      extra_config = {
    "disk.EnableUUID" = "TRUE"
}

 clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"
     customize {
      linux_options {
        host_name = "${var.worker_lan_01_name}"
        domain    = "coolcorp.priv"
      }
        network_interface {
          ipv4_address = "${var.worker_lan_01_ip_address}"
          ipv4_netmask = "${var.worker_lan_01_ip_netmask}"
      }
      ipv4_gateway = "${var.gateway_lan}"
      dns_suffix_list = ["${var.default_dns_domain}"]
      dns_server_list = ["${var.default_dns}"]
   }
  }
}