resource "local_file" "hosts_portainer_cfg" {
      depends_on = [
    null_resource.swarm_provisioner
    ]
    content = templatefile("./portainer/inventory.tmpl",
        {
            swarm_hosts = libvirt_domain.dynamic[*].network_interface.0.addresses.0
        }
    )
    filename = "./portainer/inventory.yml"
}

resource "local_file" "playbook_portainer_cfg" {
      depends_on = [
    local_file.hosts_portainer_cfg
    ]
    content = templatefile("./portainer/playbook.tmpl",
        {
            admin_password = "${var.portainer_adminpass}"
            portainer_fqdn = "${var.portainer_fqdn}"
        }
    )
    filename = "./portainer/playbook.yml"
}

resource "null_resource" "portainer_provisioner" {
  depends_on = [
    local_file.hosts_portainer_cfg
  ]
  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u root --private-key ../private_key.pem -i inventory.yml playbook.yml"
    working_dir = "${path.module}/portainer"
  }
}

resource "null_resource" "restart_portainer" {
  depends_on = [
    null_resource.portainer_provisioner
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
      "docker service update portainer_portainer --force"
    ]
  }
  lifecycle {
    replace_triggered_by = [
      null_resource.always_run
    ]
  }
}


resource "null_resource" "valide_install_portainer" {
  depends_on = [
    null_resource.restart_portainer
  ]
  provisioner "local-exec" {
    command = "until [[ $? = 60 ]] ; do sleep 1 ; curl -s https://${libvirt_domain.dynamic.0.network_interface.0.addresses[0]}:9443 2> /dev/null; done; echo youpi "
    
  }
  lifecycle {
    replace_triggered_by = [
      null_resource.always_run
    ]
  }
}

resource "local_file" "add_stack_cfg" {
      depends_on = [
    null_resource.valide_install_portainer
    ]
    content = templatefile("./script.sh/add_stack.tmpl",
        {
            admin_password = "${var.portainer_adminpass}"
        }
    )
    filename = "./script.sh/add_stack.sh"
}
resource "null_resource" "push_add_stack_sh" {
  depends_on = [local_file.add_stack_cfg]
  connection {
      host     = "${libvirt_domain.dynamic.0.network_interface.0.addresses[0]}"
      type     = "ssh"
      user     = "root"
      private_key = tls_private_key.terrafrom_generated_private_key.private_key_openssh
      timeout = var.timeout_ssh
  }

  provisioner "file" {
    source      = "script.sh/add_stack.sh"
    destination = "/srv/docker_swarm/configuration/add_stack.sh"
  }
}