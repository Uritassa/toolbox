terraform {
  backend "s3" {
    bucket = "" // TODO: replace with your bucket
    key    = "terraform/terraform.tfstate"
    region = "" // TODO: replace with your region
    encrypt = true
  }
}