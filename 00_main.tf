#### Génération clef SSH random
# ED25519 key marche pas :-(
resource "tls_private_key" "terrafrom_generated_private_key" {
  algorithm = "ED25519"
  #rsa_bits  = 4096
}
resource "local_sensitive_file" "private_key" {
  content         = tls_private_key.terrafrom_generated_private_key.private_key_openssh
  filename        = "private_key.pem"
  file_permission = "400"
}



