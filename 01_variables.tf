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