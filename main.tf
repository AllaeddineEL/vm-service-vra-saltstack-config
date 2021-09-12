module "ssconfig" {
  source = "./vra-ssconfig-module"

  ### vsphere variables
  datacenter = "Pacific-Datacenter"
  cluster    = "Workload-Cluster"
  datastore  = "vsanDatastore"
  host       = "pacific-esxi-1.haas-444.pez.vmware.com"
  network    = "DVPG-Management Network"

  ### appliance variables
  vm_name     = "vrassconfig"
  mgmt_ip     = "10.213.128.50" # the static ip of ssconfig service
  default_gw  = "10.213.128.1"
  dns_servers = "10.192.2.10,10.192.2.11"

  ssconfig_password = var.ssconfig_password
}
################## NSX-T Networking ##############
module "centos_vm" {
  depends_on        = [module.ssconfig]
  source            = "./vm-service-module"
  vm_name           = "centos-vm-service"
  ssconfig_ip       = module.ssconfig.ssconfig_ip
  vsphere_namespace = "demo"
}
module "ubuntu_vm" {
  depends_on        = [module.ssconfig]
  source            = "./vm-service-module"
  vm_name           = "ubuntu-vm-service"
  vm_image_name     = "ubuntu-20-1621373774638"
  ssconfig_ip       = module.ssconfig.ssconfig_ip
  vsphere_namespace = "demo"
}
################## AVI Networking ###############
# module "centos_vm" {
#   source            = "./vm-service-module"
#   vm_name           = "centos-vm-service"
#   ssconfig_ip       = "10.213.128.50" #module.ssconfig.ssconfig_ip
#   vsphere_namespace = "demo"
#   vm_networking     = "vsphere-distributed"
#   vm_network_name   = "workload-1"
#   vm_storage_class  = "tanzu"
# }
# module "ubuntu_vm" {
#   source            = "./vm-service-module"
#   vm_name           = "ubuntu-vm-service"
#   vm_image_name     = "ubuntu-20-1621373774638"
#   ssconfig_ip       = "10.213.128.50" #module.ssconfig.ssconfig_ip
#   vsphere_namespace = "demo"
#   vm_networking     = "vsphere-distributed"
#   vm_network_name   = "workload-1"
#   vm_storage_class  = "tanzu"
# }
