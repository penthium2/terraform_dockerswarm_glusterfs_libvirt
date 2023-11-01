###Variables :
variable "number_vm" {
  description = "Number of vm"
  default     = 2
}
variable "path_pool" {
  type        = string
  description = "path to vm"
  default     = "/home/penthium2/vm/terraform/pool"
}
variable "path_img" {
  type        = string
  description = "path for img libvirt base"
  default     = "/home/penthium2/vm"
}
variable "vm_image" {
  type        = string
  description = "VM image to use for deployment - valid = centos_stream_8, centos_stream_9, debian_bookworm, debian_bulleyes"
  default     = "Fedora-Cloud-Base-38-1.6.x86_64.qcow2"
}
variable "ram" {
  type        = string
  description = "Taille de la RAM size in byte"
  default     = "4096"
}
variable "vcpu" {
  type        = string
  description = "Nombre de VCPU"
  default     = "4"
}
variable "size" {
  type        = string
  description = "size in byte"
  default     = "15032385536"
}
variable "timeout_ssh" {
  type        = string
  description = "timeout max des tentative SSH"
  default     = "15m"
}