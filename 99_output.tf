#############output : 
 output "VM_information" {
   depends_on = [
     null_resource.valide_install_portainer
   ]
  value = {
    IPs_du_cluster = libvirt_domain.dynamic[*].network_interface.0.addresses.0
  }
}
output "Information_portainer" {
  depends_on = [
     null_resource.valide_install_portainer
   ]
  value = {
      portainer = "Ajoutez si vous avez pas de dns : \n\t${libvirt_domain.dynamic.0.network_interface.0.addresses[0]} ${var.portainer_fqdn} dans votre fichier hosts.\nconnectez vous ici : http://${var.portainer_fqdn}\nlogin : admin\nmot de passe : ${random_password.portainer_password.result}"
    }
    sensitive = true

}
output "ctfd_information" {
  value = {
   ctfd = "Ajoutez si vous avez pas de dns : \n\t${libvirt_domain.dynamic.0.network_interface.0.addresses[0]} ${var.ctfd_fqdn} dans votre fichier hosts.\nconnectez vous ici : http://${var.ctfd_fqdn}"
  }

}
output "Information"{
  value = {
    Information = "Pour afficher le login/pass de portainer faire : terraform output Information_portainer"
  }
}