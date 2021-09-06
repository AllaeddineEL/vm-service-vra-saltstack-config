
variable "vm_name" {

}
variable "vm_image_name" {
  default = "centos-stream-8-vmservice-v1alpha1-1619529007339"
}
variable "vm_class_name" {
  default = "best-effort-small"
}
variable "vm_networking" {
  default = "nsx-t"
}
variable "ssconfig_ip" {

}
variable "vm_storage_class" {
  default = "pacific-gold-storage-policy"
}
