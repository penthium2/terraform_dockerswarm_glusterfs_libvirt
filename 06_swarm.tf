resource "local_file" "hosts_swarm_cfg" {
       depends_on = [
     null_resource.glusterfs_provisioner
     ]
    content = templatefile("./swarm/inventory.tmpl",
        {
            swarm_hosts = libvirt_domain.dynamic[*].network_interface.0.addresses.0
        }
    )
    filename = "./swarm/inventory.yml"
    lifecycle {
    replace_triggered_by = [
        null_resource.always_run
        ]
    #create_before_destroy = true
  }
}
resource "local_file" "playbook_swarm_cfg" {
    depends_on = [
      local_file.hosts_swarm_cfg
    ]
    content = templatefile("./swarm/playbook.tmpl",
        {
            master = "${libvirt_domain.dynamic.0.network_interface.0.addresses.0}"
        }
    )
    filename = "./swarm/playbook.yml"
    lifecycle {
      replace_triggered_by = [
      null_resource.always_run
    ]
    create_before_destroy = true
  }
}


resource "null_resource" "swarm_provisioner" {
    depends_on = [
      local_file.playbook_swarm_cfg
  ]
  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u root --private-key ../private_key.pem -i inventory.yml playbook.yml"
    working_dir = "${path.module}/swarm"
  }
  lifecycle {
    replace_triggered_by = [
      null_resource.always_run
    ]
    create_before_destroy = true
  }
}


