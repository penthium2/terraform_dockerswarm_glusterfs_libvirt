#############output : 
output "Vm_ip" {
  value = libvirt_domain.dynamic[*].network_interface.0.addresses
}
