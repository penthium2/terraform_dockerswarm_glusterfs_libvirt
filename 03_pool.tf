###### Pool :

resource "libvirt_pool" "terraform" {
  name = "terraform"
  type = "dir"
  path = var.path_pool
}

#####