resource "local_file" "hosts_cfg" {
    content = templatefile("./ansible/inventory.tmpl",
        {
            swarm_hosts = libvirt_domain.dynamic[*].network_interface.0.addresses.0
        }
    )
    filename = "./ansible/inventory.yml"
}
resource "null_resource" "ansible_provisioner" {
  depends_on = [
    local_file.hosts_cfg
  ]
  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u root --private-key ../private_key.pem -i inventory.yml playbook.yml"
    working_dir = "${path.module}/ansible"
  }
}