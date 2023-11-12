resource "local_file" "hosts_portainer_cfg" {
      depends_on = [
    null_resource.glusterfs_provisioner
    ]
    content = templatefile("./portainer/inventory.tmpl",
        {
            swarm_hosts = libvirt_domain.dynamic[*].network_interface.0.addresses.0
        }
    )
    filename = "./portainer/inventory.yml"
#    lifecycle {
#    replace_triggered_by = [
#      null_resource.always_run
#    ]
#    create_before_destroy = true
#  }
}

resource "local_file" "playbook_portainer_cfg" {
      depends_on = [
    null_resource.glusterfs_provisioner
    ]
    content = templatefile("./portainer/playbook.tmpl",
        {
            admin_password = "${var.portainer_adminpass}"
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

resource "null_resource" "valide_install_portainer" {
  depends_on = [
    null_resource.portainer_provisioner
  ]
  provisioner "local-exec" {
    command = "until [[ $? = 60 ]] ; do sleep 1 ; curl -s https://${libvirt_domain.dynamic.0.network_interface.0.addresses[0]}:9443 2> /dev/null; done; echo youpi "
    
  }
}