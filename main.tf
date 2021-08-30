terraform {
  required_providers {
    vsphere = "~> 2.0"
  }
}
provider "vsphere" {
  vsphere_server       = "10.213.126.14"
  user                 = "administrator@vsphere.local"
  password             = var.vc_password
  allow_unverified_ssl = true
}

module "avi-controller" {
  source = "./vra-ssconfig-module"

  ### vsphere variables
  datacenter = "Pacific-Datacenter"
  cluster    = "Workload-Cluster"
  datastore  = "vsanDatastore"
  host       = "pacific-esxi-1.haas-486.pez.vmware.com"
  network    = "DVPG-Management Network"

  ### appliance variables
  vm_name    = "vrassconfig"
  mgmt-ip    = "10.213.126.52"
  mgmt-mask  = "255.255.255.0"
  default-gw = "10.213.126.1"

  ### initial config
  admin-password = var.ssconfig_password
}
