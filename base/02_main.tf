# ED25519 key
resource "tls_private_key" "terrafrom_generated_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096

}

resource "local_sensitive_file" "private_key" {
  content         = tls_private_key.terrafrom_generated_private_key.private_key_pem
  filename        = "private_key.pem"
  file_permission = "400"
}

data "template_file" "cloudinit" {
  template = file("${path.module}/cloud-init.yml")

  vars = {
    root_sshkey    = trimspace(tls_private_key.terrafrom_generated_private_key.public_key_openssh)
    private_sshkey = tls_private_key.terrafrom_generated_private_key.private_key_pem
  }
}

data "cloudinit_config" "conf" {
  gzip          = false
  base64_encode = false
  part {
    content_type = "text/cloud-config"
    content      = data.template_file.cloudinit.rendered
    filename     = "cloud-init.yaml"
  }
}

resource "random_password" "ceph_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}
