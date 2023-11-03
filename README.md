# Docker Swarm avec GlusterFS via Terraform sur libvirt

Ce projet est une maquette permetant l'installation automatique de X vm avec automatiquement dockerswarm installé et initialisé avec que des nodes manager.

Il y a aussi un système de fichier distribué de type glusterFS pour la redondance des donné des conteneurs.

Toute cette infra est intallé dans X vm linux dans un KVM/Qemu via libvirt.

Et biensur tout est automatisé via terraform.


## fichier prod.auto.tfvars.example :

Ce fichier est un exemple du fichier prod.auto.tf

    number_vm = 3
    Nombre de vms

    path_pool = "/home/penthium2/vm/terraform/pool"
    répertoire pour les disques des vms

    path_img = "/home/penthium2/vm"
    chemin de l'image de base a utilisé
    
    vm_image =  "Fedora-Cloud-Base-38-1.6.x86_64.qcow2"
    Nom de l'image a utilisé

    name_vm = "swarm-"
    Nom de base des vm

    ram     = 4096
    quantité de ram

    vcpu = 4
    Nombre de vCPU

    size = 25032385536
    Taille de l'espace racine

    timeout_ssh = "15m"
    Durée pour garantir la fin du cloundinit.

Ce terraform génère automatiquement un clef privée ssh pour se conecté au VM via la commande : 

    ssh -i ./private_key.pem root@192.168.124.167

## Lancement :

    terraform init
    terraform apply

## Destruction :

    terraform destroy
