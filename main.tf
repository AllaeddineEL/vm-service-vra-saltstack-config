terraform {
  required_providers {
    vsphere = "~> 2.0"
    kubernetes-alpha = {
      source  = "hashicorp/kubernetes-alpha"
      version = "0.6.0"
    }
  }
}
provider "vsphere" {
  vsphere_server       = "10.213.128.14"
  user                 = "administrator@vsphere.local"
  password             = var.vc_password
  allow_unverified_ssl = true
}
provider "kubernetes-alpha" {
  config_path = "~/.kube/config" // path to kubeconfig
}

module "avi-controller" {
  source = "./vra-ssconfig-module"

  ### vsphere variables
  datacenter = "Pacific-Datacenter"
  cluster    = "Workload-Cluster"
  datastore  = "vsanDatastore"
  host       = "pacific-esxi-1.haas-444.pez.vmware.com"
  network    = "DVPG-Management Network"

  ### appliance variables
  vm_name     = "vrassconfig"
  mgmt_ip     = "10.213.128.50"
  default_gw  = "10.213.128.1"
  dns_servers = "10.192.2.10,10.192.2.11"

  ### initial config
  ssconfig_password = var.ssconfig_password
}

module "centos_vm" {
  source = "./vm-service-module"
}
