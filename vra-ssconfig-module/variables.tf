### vsphere variables
variable "datacenter" {}
variable "cluster" {}
variable "datastore" {}
variable "host" {}
variable "network" {}

### appliance variables
variable "vm_name" {}
variable "mgmt_ip" {}
variable "mgmt_mask" {
    default = "255.255.255.0"
}
variable "default_gw" {}
variable "num_cpus" {
    default = 2
}
variable "memory" {
    default = 8192

}
variable "dns_servers" {
  
}

### initial config
variable "ssconfig_password" {}
