#############output : 
output "VM_information" {
  value = {
    vm = libvirt_domain.dynamic[*].network_interface.0.hostname 
    ip = libvirt_domain.dynamic[*].network_interface.0.addresses.0
  }
}
