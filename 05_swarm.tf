###### Configuration de swarm :
resource "swarm_cluster" "cluster" {
  depends_on              = [null_resource.change_Name]
  skip_manager_validation = true
  dynamic "nodes" {
    for_each = libvirt_domain.dynamic[*]
    content {
      hostname = nodes.value.name
      tags = tomap({
        "role" = "manager"
      })
      private_address = "${nodes.value.network_interface.0.addresses[0]}"
      public_address  = "${nodes.value.network_interface.0.addresses[0]}"

    }
  }
}
resource "null_resource" "firewall_docker" {
  depends_on = [swarm_cluster.cluster]
  count = var.number_vm
  connection {
      host     = "${libvirt_domain.dynamic[count.index].network_interface.0.addresses[0]}"
      type     = "ssh"
      user     = "root"
      private_key = tls_private_key.terrafrom_generated_private_key.private_key_openssh
      timeout = var.timeout_ssh
  }
  provisioner "remote-exec" {
    inline = [
      "firewall-cmd --zone=public --add-service=docker-swarm --permanent",
      "firewall-cmd --reload",
      "systemctl restart docker"
    ]
  }
  lifecycle {
    replace_triggered_by = [
      null_resource.always_run
    ]
    create_before_destroy = true
  }
}


