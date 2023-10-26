
locals {
  os = split("_", var.vm_image)[0]

}

data "template_file" "proviscript" {
  template = file("${path.module}/scripts/${local.os}.sh")

  vars = {
    SCW-BUCKET-NAME = random_pet.bucket.id
    ACCESS_KEY      = var.SCW_ACCESS_KEY
    SECRET_KEY      = var.SCW_SECRET_KEY
    FOLDER-TO-MOUNT = var.mount_folder
  }
}

resource "local_file" "rendered_script" {
  content         = data.template_file.proviscript.rendered
  filename        = "${path.module}/scripts/rendered/boot_script.sh"
  file_permission = "700"

}

resource "null_resource" "have_a_break" {
  depends_on = [
    scaleway_instance_ip.dynamic
  ]

  provisioner "local-exec" {
    command = "sleep 180" # sleep 3 minutes - maybe possible to improve speed setting up docker install on provisioning script
  }
}

resource "null_resource" "kickstart_script" {
  depends_on = [
    local_file.rendered_script,
    null_resource.have_a_break
  ]

  count = var.number_master
  connection {
    type        = "ssh"
    private_key = tls_private_key.terrafrom_generated_private_key.private_key_pem
    host        = scaleway_instance_server.dynamic[count.index].public_ip
    user        = "root"
  }
  provisioner "remote-exec" {
    script = "${path.module}/scripts/rendered/boot_script.sh"
  }

}