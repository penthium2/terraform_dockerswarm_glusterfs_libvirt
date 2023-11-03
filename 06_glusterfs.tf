## A FINIR : gestion de glusterFS :
resource "null_resource" "glusterfs" {
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
  ## fait une action sur le premier serveur et un autre action sur tous les autres serveur
  provisioner "remote-exec" {
    inline = [
      count.index == 0 ? "echo 'MASTER' >> /root/INFO" : "echo 'SLAVE' >> /root/INFO"
    ]
  }
}