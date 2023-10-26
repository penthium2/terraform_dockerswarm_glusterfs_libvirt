resource "scaleway_instance_volume" "ceph" {
  count      = var.number_master
  type       = "b_ssd"
  name       = "ceph${count.index}"
  size_in_gb = var.ceph_size
  lifecycle {
    ignore_changes = [size_in_gb]
  }
}

resource "scaleway_instance_server" "dynamic" {
  count = var.number_master
  type  = var.vm_type
  image = var.vm_image
  tags  = tolist(var.tags)
  ip_id = scaleway_instance_ip.dynamic[count.index].id

  security_group_id = scaleway_instance_security_group.ctf.id
  root_volume {
    delete_on_termination = true
    volume_type           = var.root_volume_type
    size_in_gb            = var.root_volume_size
  }
  additional_volume_ids = [scaleway_instance_volume.ceph[count.index].id]
  user_data = {
    cloud-init = "${data.cloudinit_config.conf.rendered}"
  }

}

resource "scaleway_instance_private_nic" "dynamic" {
  count              = var.number_master
  server_id          = scaleway_instance_server.dynamic[count.index].id
  private_network_id = scaleway_vpc_private_network.main.id
  
}