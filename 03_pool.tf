resource "libvirt_pool" "terraform" {
  name = "terraform"
  type = "dir"
  path = "/home/penthium2/vm/terraform/pool"
}