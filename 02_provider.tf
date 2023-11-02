###### provider : 
terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      version = "0.6.14"
    }
    swarm = {
      source = "aucloud/swarm"
    }
  }
  required_version = ">= 0.13"
}
provider "libvirt" {
  uri = "qemu:///system"
}
provider "cloudinit" {
}
provider "swarm" {
  ssh_user = "root"
  ssh_key  = "private_key.pem"
}