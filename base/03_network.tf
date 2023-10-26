# Create VPC
resource "scaleway_vpc" "main" {
  name = random_pet.bucket.id
  tags = var.tags
}

resource "scaleway_vpc_private_network" "main" {
  name        = random_pet.bucket.id
  tags        = var.tags
  vpc_id      = scaleway_vpc.main.id
}

# Network Security Rules
resource "scaleway_instance_security_group" "ctf" {
  description             = "CTF"
  name                    = "CTF ${random_pet.bucket.id}"
  inbound_default_policy  = "accept"
  outbound_default_policy = "accept"
  # disable smtp outgoing security
  enable_default_security = false
}

resource "scaleway_instance_security_group_rules" "ctf" {
  security_group_id = scaleway_instance_security_group.ctf.id

  # Ban ip from the banned_ip list
  dynamic "inbound_rule" {
    for_each = var.banned_ip
    content {
      action   = "drop"
      ip_range = inbound_rule.value
    }
  }
  # Allow All between instance private ip
  dynamic "inbound_rule" {
    for_each = scaleway_instance_server.dynamic
    content {
      action   = "accept"
      protocol = "TCP"
      ip_range = "${inbound_rule.value.private_ip}/32"
    }
  }

  dynamic "inbound_rule" {
    for_each = scaleway_instance_server.dynamic
    content {
      action   = "accept"
      protocol = "UDP"
      ip_range = "${inbound_rule.value.private_ip}/32"
    }
  }

  dynamic "inbound_rule" {
    for_each = scaleway_instance_server.dynamic
    content {
      action   = "accept"
      protocol = "ICMP"
      ip_range = "${inbound_rule.value.private_ip}/32"
    }
  }
  ####
  # Allow All between instance public ip
  dynamic "inbound_rule" {
    for_each = scaleway_instance_server.dynamic
    content {
      action   = "accept"
      protocol = "TCP"
      ip_range = "${inbound_rule.value.public_ip}/32"
    }
  }

  dynamic "inbound_rule" {
    for_each = scaleway_instance_server.dynamic
    content {
      action   = "accept"
      protocol = "UDP"
      ip_range = "${inbound_rule.value.public_ip}/32"
    }
  }

  dynamic "inbound_rule" {
    for_each = scaleway_instance_server.dynamic
    content {
      action   = "accept"
      protocol = "ICMP"
      ip_range = "${inbound_rule.value.public_ip}/32"
    }
  }


  # Allow All from trusted ip
  dynamic "inbound_rule" {
    for_each = var.trusted_ip
    content {
      action   = "accept"
      ip_range = inbound_rule.value
    }
  }

  # Drop on inbound of the drop_port list
  dynamic "inbound_rule" {
    for_each = var.drop_port
    content {
      action = "drop"
      port   = inbound_rule.value
    }
  }
  # Drop all ICMP
  inbound_rule {
    action   = "drop"
    protocol = "ICMP"
  }

}

# Generate public IP
resource "scaleway_instance_ip" "dynamic" {
  count = var.number_master
}
