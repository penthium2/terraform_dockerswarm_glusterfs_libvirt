resource "libvirt_volume" "dynamic" {
  count  = var.number_vm
  name   = "vm${count.index}.qcow2"
  format = "qcow2"
  pool   = libvirt_pool.terraform.name
  source = "/home/penthium2/vm/Fedora-Cloud-Base-38-1.6.x86_64.qcow2"
}
resource "libvirt_domain" "dynamic" {
  count  = var.number_vm
  name   = "vm${count.index}"
  memory = "512"
  vcpu   = 1

  network_interface {
    network_name = "default"
  }

  disk {
    volume_id = libvirt_volume.dynamic[count.index].id 
  }
}