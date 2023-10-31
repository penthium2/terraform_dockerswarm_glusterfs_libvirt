###### VM :
resource "libvirt_volume" "dynamic" {
  count  = var.number_vm
  name   = "vm${count.index}.qcow2"
  format = "qcow2"
  pool   = libvirt_pool.terraform.name
  source = "${var.path_img}/Fedora-Cloud-Base-38-1.6.x86_64.qcow2"
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
    volume_id = libvirt_volume.dynamic[count.index].id 
  }
#  user_data = {
#    cloud-init = "${data.cloudinit_config.conf.rendered}"
#  }
  cloudinit = libvirt_cloudinit_disk.commoninit.id
  
  console {
    type = "pty"
    target_type = "serial"
    target_port = "0"
  }
}