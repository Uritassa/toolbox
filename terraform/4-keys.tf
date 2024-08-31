resource "tls_private_key" "keypair" {
  algorithm = "RSA"
  rsa_bits  = 4096
  lifecycle { 
    ignore_changes = [algorithm, rsa_bits]
  }
}
data "tls_public_key" "keypair" {
  private_key_pem = tls_private_key.keypair.private_key_pem
}

resource "aws_key_pair" "keypair" {
  depends_on = [tls_private_key.keypair]
  key_name   = var.key_name
  public_key = data.tls_public_key.keypair.public_key_openssh
  lifecycle {
    ignore_changes = [public_key]
  }
}

resource "local_file" "private_key_pem" {
  depends_on = [tls_private_key.keypair]
  filename = "${path.module}/${var.name}-key.pem"
  content  = tls_private_key.keypair.private_key_pem
}



output "private_key_pem" {
    value     = local_file.private_key_pem.filename
    sensitive = false
}