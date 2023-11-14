#############output : 
 output "VM_information" {
   depends_on = [
     null_resource.valide_install_portainer
   ]
  value = {
    IPs_du_cluster = libvirt_domain.dynamic[*].network_interface.0.addresses.0
    portainer = "connectez vous ici : https://${libvirt_domain.dynamic.0.network_interface.0.addresses[0]}:9443\nlogin : admin\nmot de passe : ${var.portainer_adminpass}"
  }
}
