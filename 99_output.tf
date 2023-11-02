#############output : 
output "VM_information" {
  value = [libvirt_domain.dynamic[*].network_interface.0.hostname, libvirt_domain.dynamic[*].network_interface.0.addresses.0]
}
