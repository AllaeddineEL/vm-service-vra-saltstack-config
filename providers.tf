terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.11.3"
    }
  }
}
provider "vsphere" {
  vsphere_server       = "10.213.128.14"
  user                 = "administrator@vsphere.local"
  password             = var.vc_password
  allow_unverified_ssl = true
}
provider "kubernetes" {
  config_path = "~/.kube/config"
  experiments {
    manifest_resource = true
  }
}
provider "kubectl" {
  config_path = "~/.kube/config"
}
