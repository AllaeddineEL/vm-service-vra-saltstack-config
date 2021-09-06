data "vsphere_datacenter" "datacenter" {
  name = var.datacenter
}

data "vsphere_datastore" "datastore" {
  name          = var.datastore
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.cluster
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_host" "host" {
  name          = var.host
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "network" {
  name          = var.network
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_ovf_vm_template" "ovf" {
  name             = var.vm_name
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  host_system_id   = data.vsphere_host.host.id
  local_ovf_path   = "${path.root}/artifacts/VMware-vRealize-Automation-SaltStack-Config-8.5.0.0-18427593_OVF10.ova"

  ovf_network_map = {
    "Management" = data.vsphere_network.network.id
  }
}

resource "vsphere_virtual_machine" "vm" {
  annotation    = "VMware vRealize Automation SaltStack Config"
  datacenter_id = data.vsphere_datacenter.datacenter.id
  name          = data.vsphere_ovf_vm_template.ovf.name
  num_cpus      = var.num_cpus # data.vsphere_ovf_vm_template.ovf.num_cpus
  memory        = var.memory   #data.vsphere_ovf_vm_template.ovf.memory
  guest_id      = data.vsphere_ovf_vm_template.ovf.guest_id

  resource_pool_id = data.vsphere_ovf_vm_template.ovf.resource_pool_id
  datastore_id     = data.vsphere_ovf_vm_template.ovf.datastore_id
  host_system_id   = data.vsphere_ovf_vm_template.ovf.host_system_id

  dynamic "network_interface" {
    for_each = data.vsphere_ovf_vm_template.ovf.ovf_network_map
    content {
      network_id = network_interface.value
    }
  }
  ovf_deploy {
    disk_provisioning = "thin"
    ovf_network_map   = data.vsphere_ovf_vm_template.ovf.ovf_network_map
    #remote_ovf_url    = data.vsphere_ovf_vm_template.ovf.remote_ovf_url
    local_ovf_path = "${path.root}/artifacts/VMware-vRealize-Automation-SaltStack-Config-8.5.0.0-18427593_OVF10.ova"
  }
  vapp {
    properties = {
      "vami.hostname"   = data.vsphere_ovf_vm_template.ovf.name
      "varoot-password" = var.ssconfig_password
      "ip0"             = var.mgmt_ip
      "netmask0"        = var.mgmt_mask
      "gateway"         = var.default_gw
      "DNS"             = var.dns_servers
    }
  }
  lifecycle {
    ignore_changes = [
      host_system_id,
      vapp[0].properties["varoot-password"]
    ]
  }
}

resource "null_resource" "copy_license" {
  triggers = {
    ssconfig_addresse = vsphere_virtual_machine.vm.guest_ip_addresses[0]
  }

  provisioner "file" {
    source      = "${path.root}/artifacts/raas.license"
    destination = "/etc/raas/raas.license"
    connection {
      type     = "ssh"
      user     = "root"
      password = var.ssconfig_password
      host     = vsphere_virtual_machine.vm.guest_ip_addresses[0]
    }
  }


  provisioner "remote-exec" {
    inline = [
      "chown raas:raas /etc/raas/raas.license",
      "chmod 400 /etc/raas/raas.license",
      "systemctl restart raas"
    ]
    connection {
      type     = "ssh"
      user     = "root"
      password = var.ssconfig_password
      host     = vsphere_virtual_machine.vm.guest_ip_addresses[0]
    }
  }
}
resource "null_resource" "copy_salt_job" {
  triggers = {
    ssconfig_addresse = vsphere_virtual_machine.vm.guest_ip_addresses[0]
  }

  provisioner "file" {
    source      = "${path.root}/artifacts/salt-job"
    destination = "/root"
    connection {
      type     = "ssh"
      user     = "root"
      password = var.ssconfig_password
      host     = vsphere_virtual_machine.vm.guest_ip_addresses[0]
    }
  }


  provisioner "remote-exec" {
    inline = [
      "python3 /root/salt-job/salt-env.py",
    ]
    connection {
      type     = "ssh"
      user     = "root"
      password = var.ssconfig_password
      host     = vsphere_virtual_machine.vm.guest_ip_addresses[0]
    }
  }
}

# resource "null_resource" "updateuser" {
#   triggers = {
#     avi-endpoint = "avic.lab01.one"
#     avi-username = "admin"
#     avi-oldpass  = "58NFaGDJm(PJH0G"
#     avi-newpass  = var.admin-password
#   }
#   provisioner "local-exec" {
#     interpreter = ["/bin/bash", "-c"]
#     command     = "${path.module}/updateuser.sh"
#     environment = {
#       ENDPOINT = self.triggers.avi-endpoint
#       AVIUSER  = self.triggers.avi-username
#       OLDPASS  = self.triggers.avi-oldpass
#       NEWPASS  = self.triggers.avi-newpass
#     }
#   }
#   depends_on = [
#     null_resource.healthcheck
#   ]
# }
