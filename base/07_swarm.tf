# After a break configure docker swarm
resource "swarm_cluster" "cluster" {
  depends_on              = [null_resource.kickstart_script]
  skip_manager_validation = true
  dynamic "nodes" {
    for_each = concat(scaleway_instance_server.dynamic)
    content {
      hostname = nodes.value.name
      tags = tomap({
        "role" = "manager"
      })
      private_address = nodes.value.private_ip
      public_address  = nodes.value.public_ip

    }
  }
  lifecycle {
    prevent_destroy = false
  }
}
