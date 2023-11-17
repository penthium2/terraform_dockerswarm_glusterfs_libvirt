
resource "null_resource" "directory_traefik" {
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
      "mkdir -p /srv/docker_swarm/docker/traefik/log",
      "mkdir -p /srv/docker_swarm/configuration/compose/traefik"
    ]
  }
}

resource "null_resource" "push_compose" {
  depends_on = [null_resource.directory_traefik]
  connection {
      host     = "${libvirt_domain.dynamic.0.network_interface.0.addresses[0]}"
      type     = "ssh"
      user     = "root"
      private_key = tls_private_key.terrafrom_generated_private_key.private_key_openssh
      timeout = var.timeout_ssh
  }
  provisioner "file" {
    source      = "traefik/traefik.yml"
    destination = "/srv/docker_swarm/configuration/compose/traefik/traefik.yml"
  }
}
resource "null_resource" "load_stack_traefik" {
  depends_on = [
    null_resource.push_compose
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
      "/srv/docker_swarm/configuration/add_stack.sh traefik /srv/docker_swarm/configuration/compose/traefik/traefik.yml"
    ]
  }
}
resource "null_resource" "restart_traefik" {
  depends_on = [
    null_resource.restart_portainer
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
      "sleep 30",
      "docker service update traefik_traefik --force"
    ]
  }
  lifecycle {
    replace_triggered_by = [
      null_resource.always_run
    ]
  }
}
