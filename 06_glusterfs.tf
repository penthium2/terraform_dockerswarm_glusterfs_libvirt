## A FINIR : gestion de glusterFS :
resource "null_resource" "glusterfs_install" {
  depends_on = [
    null_resource.change_Name
  ]
  count = var.number_vm
  connection {
      host     = "${libvirt_domain.dynamic[count.index].network_interface.0.addresses[0]}"
      type     = "ssh"
      user     = "root"
      private_key = tls_private_key.terrafrom_generated_private_key.private_key_openssh
      timeout = var.timeout_ssh
  }

  provisioner "remote-exec" {
    script = "${path.module}/script.sh/glusterfs_all.sh"
  }
}

data "template_file" "master" {
  template = file("${path.module}/script.sh/glusterfs_master.sh")

  vars = {
    VM = var.name_vm
  }
}
resource "local_file" "rendered_script" {
  content         = data.template_file.master.rendered
  filename        = "${path.module}/scripts/rendered/master.sh"
  file_permission = "700"

}
resource "null_resource" "glusterfs_master" {
  depends_on = [
    null_resource.glusterfs_install,
    local_file.rendered_script
  ]
  count = var.number_vm
  connection {
      host     = "${libvirt_domain.dynamic[count.index].network_interface.0.addresses[0]}"
      type     = "ssh"
      user     = "root"
      private_key = tls_private_key.terrafrom_generated_private_key.private_key_openssh
      timeout = var.timeout_ssh
  }
  provisioner "remote-exec" {
    script = count.index == 0 ? "${path.module}/scripts/rendered/master.sh" : "${path.module}/script.sh/echonope.sh"
    
  }
  ## fait une action sur le premier serveur et un autre action sur tous les autres serveur
  #provisioner "remote-exec" {
  #  inline = [
  #    count.index == 0 ? "echo 'MASTER' >> /root/INFO" : "echo 'SLAVE' >> /root/INFO"
  #  ]
  #}
}

resource "null_resource" "glusterfs_mount" {
  depends_on = [
    null_resource.glusterfs_master
  ]
  count = var.number_vm
  connection {
      host     = "${libvirt_domain.dynamic[count.index].network_interface.0.addresses[0]}"
      type     = "ssh"
      user     = "root"
      private_key = tls_private_key.terrafrom_generated_private_key.private_key_openssh
      timeout = var.timeout_ssh
  }

  provisioner "remote-exec" {
    script = "${path.module}/script.sh/glusterfs_mount.sh"
  }
}