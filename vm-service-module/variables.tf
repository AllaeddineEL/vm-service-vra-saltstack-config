
variable "vm_name" {

}
variable "vsphere_namespace" {

}
variable "vm_image_name" {
  default = "centos-stream-8-vmservice-v1alpha1-1619529007339"
}
variable "vm_class_name" {
  default = "best-effort-small"
}
variable "vm_networking" {
  default = "nsx-t"
  validation {
    condition     = can(regex("nsx-t|vsphere-distributed", var.vm_networking))
    error_message = "ERROR: Invalid VM Networking input. It must be either nsx-t or vsphere-distributed ..."
  }
}
variable "vm_network_name" {
  default = ""
}
variable "ssconfig_ip" {

}
variable "vm_storage_class" {
  default = "pacific-gold-storage-policy"
}
variable "vm_ssh_enabled" {
  default = false
}
