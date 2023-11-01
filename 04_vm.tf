###### VM :
resource "libvirt_volume" "dynamic" {
  count  = var.number_vm
  name   = "vm${count.index}"
  format = "qcow2"
  pool   = libvirt_pool.terraform.name
  source = "${var.path_img}/${var.vm_image}"
}
resource "libvirt_volume" "final_dynamic" {
  count  = var.number_vm
  name   = "vm${count.index}.qcow2"
  pool   = libvirt_pool.terraform.name
  base_volume_id = libvirt_volume.dynamic[count.index].id
  size            = var.size
}
data "template_file" "cloudinit" {
  template = file("${path.module}/cloud-init.yml")
  vars = {
    root_sshkey    = trimspace(tls_private_key.terrafrom_generated_private_key.public_key_openssh)
    private_sshkey = tls_private_key.terrafrom_generated_private_key.private_key_openssh
  }
}
data "cloudinit_config" "conf" {
  gzip          = false
  base64_encode = false
  part {
    content_type = "text/cloud-config"
    content      = data.template_file.cloudinit.rendered
    filename     = "cloud-init.yaml"
  }
}
resource "libvirt_cloudinit_disk" "commoninit" {
  name           = "commoninit.iso"
  pool           =  libvirt_pool.terraform.name
  user_data      = data.cloudinit_config.conf.rendered
}
resource "libvirt_domain" "dynamic" {
  count  = var.number_vm
  name   = "vm${count.index}"
  memory = "2028"
  vcpu   = 1
  network_interface {
    network_name = "default"
    #permet d'attendre la couche réseau pour avoir les ips dans output :
    wait_for_lease= true
  }
  disk {
    volume_id = libvirt_volume.final_dynamic[count.index].id 
  }
  cloudinit = libvirt_cloudinit_disk.commoninit.id
    console {
    type = "pty"
    target_type = "serial"
    target_port = "0"
  }
  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait",
    ]

    connection {
      host     = "${self.network_interface.0.addresses.0}"
      type     = "ssh"
      user     = "root"
      private_key = tls_private_key.terrafrom_generated_private_key.private_key_openssh
    }
  }
}