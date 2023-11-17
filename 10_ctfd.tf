
resource "null_resource" "directory_ctfd" {
  depends_on = [
    null_resource.valide_install_portainer
  ]
  connection {
      host     = "${libvirt_domain.dynamic.0.network_interface.0.addresses[0]}"
      type     = "ssh"
      user     = "root"
      private_key = tls_private_key.terrafrom_generated_private_key.private_key_openssh
      timeout = var.timeout_ssh
  }
  provisioner "remote-exec" {
    inline = [
      "mkdir -p /srv/docker_swarm/configuration/compose/ctfd",
      "mkdir -p /srv/docker_swarm/docker/ctfd/ctfd/logs",
      "mkdir -p /srv/docker_swarm/docker/ctfd/ctfd/uploads",
      "mkdir -p /srv/docker_swarm/docker/ctfd//nginx",
      "mkdir -p /srv/docker_swarm/docker/ctfd/mysql",
      "mkdir -p /srv/docker_swarm/docker/ctfd/redis"
    ]
  }
}

resource "random_password" "sql_password" {
  length           = 16
  special          = false
}
resource "random_password" "secretkey_password" {
  length           = 109
  special          = false
}

resource "local_file" "ctfd_cfg" {
      depends_on = [
    null_resource.valide_install_portainer
    ]
    content = templatefile("./ctfd/ctfd.tmpl",
        {
            ctfd_fdqn = "${var.ctfd_fqdn}"
            key = "${random_password.secretkey_password.result}"
            sql = "${random_password.sql_password.result}"
        }
    )
    filename = "./ctfd/ctfd.yml"
}
resource "null_resource" "push_ctfd_compose" {
  depends_on = [null_resource.directory_ctfd]
  connection {
      host     = "${libvirt_domain.dynamic.0.network_interface.0.addresses[0]}"
      type     = "ssh"
      user     = "root"
      private_key = tls_private_key.terrafrom_generated_private_key.private_key_openssh
      timeout = var.timeout_ssh
  }
  provisioner "file" {
    source      = "ctfd/ctfd.yml"
    destination = "/srv/docker_swarm/configuration/compose/ctfd/ctfd.yml"
  }
}
resource "null_resource" "push_nginx_conf" {
  depends_on = [null_resource.directory_ctfd]
  connection {
      host     = "${libvirt_domain.dynamic.0.network_interface.0.addresses[0]}"
      type     = "ssh"
      user     = "root"
      private_key = tls_private_key.terrafrom_generated_private_key.private_key_openssh
      timeout = var.timeout_ssh
  }
  provisioner "file" {
    source      = "ctfd/http.conf"
    destination = "/srv/docker_swarm/docker/ctfd//nginx/http.conf"
  }
}
resource "null_resource" "load_stack_ctfd" {
  depends_on = [
    null_resource.push_nginx_conf
  ]
  connection {
      host     = "${libvirt_domain.dynamic.0.network_interface.0.addresses[0]}"
      type     = "ssh"
      user     = "root"
      private_key = tls_private_key.terrafrom_generated_private_key.private_key_openssh
      timeout = var.timeout_ssh
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /srv/docker_swarm/configuration/add_stack.sh",
      "/srv/docker_swarm/configuration/add_stack.sh ctfd /srv/docker_swarm/configuration/compose/ctfd/ctfd.yml",
      "echo 'attente initialisation complete de la stack'",
      "sleep 180"
    ]
  }
}