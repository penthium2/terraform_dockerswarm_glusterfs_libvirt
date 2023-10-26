variable "SCW_PROJECT_ID" {
  type        = string
  description = "Scaleway Project ID"
  sensitive   = true

}
variable "SCW_ACCESS_KEY" {
  type        = string
  description = "Scaleway Access Key"
  sensitive   = true
}
variable "SCW_SECRET_KEY" {
  type        = string
  description = "Scaleway Secret Key"
  sensitive   = true
}

variable "number_master" {
  description = "Number of Master nodes"
  default     = 3
}

variable "vm_type" {
  type        = string
  description = "DEV1-S for testing - Minimum PLAY2-MICRO for prod"
  default     = "DEV1-S"
}

variable "vm_image" {
  type        = string
  description = "VM image to use for deployment - valid = centos_stream_8, centos_stream_9, debian_bookworm, debian_bulleyes"
  default     = "centos_stream_9"

}

variable "root_volume_type" {
  type    = string
  default = "b_ssd"
}

variable "root_volume_size" {
  type    = string
  default = 20
}

variable "ceph_size" {
  type    = string
  default = 35
}

variable "tags" {
  type = list(string)
  default = [
    "Env   = DEVELOP",
    "Event = Demo",
    "Type  = CTF"
  ]
}

variable "mount_folder" {
  default = "/mnt/bucket"
}

variable "trusted_ip" {
  description = "Ip Range to allow"
  default = [
    "127.0.0.1/32",
    "127.0.0.2/32"
  ]
}

variable "banned_ip" {
  description = "Ip Range to ban"
  default = [
    "88.129.243.78/32",
    "58.57.83.242/32"
  ]
}
variable "drop_port" {
  description = "Port that will be force drop for untrusted ip range"
  default = [
    22,
    2377,
    7946,
    4789,
    8443
  ]
}
