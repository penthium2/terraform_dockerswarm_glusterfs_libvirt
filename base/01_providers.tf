terraform {
  required_providers {
    scaleway = {
      source = "scaleway/scaleway"
    }
    swarm = {
      source = "aucloud/swarm"

    }

  }
  required_version = ">= 0.13"
}

provider "cloudinit" {
}

provider "scaleway" {
  access_key = var.SCW_ACCESS_KEY
  secret_key = var.SCW_SECRET_KEY
  project_id = var.SCW_PROJECT_ID
  zone       = "fr-par-1"
  region     = "fr-par"
}

provider "swarm" {
  ssh_user = "root"
  ssh_key  = "private_key.pem"
}