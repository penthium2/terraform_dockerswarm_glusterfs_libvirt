output "private_ip" {
  value = libvirt_domain.dynamic[*].network_interface[*].addresses
}