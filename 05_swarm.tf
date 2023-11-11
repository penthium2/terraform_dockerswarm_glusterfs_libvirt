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
  lifecycle {
    replace_triggered_by = [
      null_resource.always_run
    ]
    create_before_destroy = true
  }
}