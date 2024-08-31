
variable "name" {
    default = "temp" // TODO: replace with your project name
}


variable "region" { 
    default = "us-west-1" // TODO: replace with your region
}

variable "availability_zones" {  // TODO: replace with the region az
    default = ["us-west-1a", "us-west-1c"]
}

variable "cidr_block" {
    default = "10.0.0.0/16"
}

variable "az1_cidr_block" {
    default = "10.0.10.0/24"
}

variable "az2_cidr_block" {
    default = "10.0.20.0/24" 
}

variable "private_az1_cidr_block" {
    default = "10.0.30.0/24"
}

variable "private_az2_cidr_block" {
    default = "10.0.40.0/24"
}


################ EC2 #####################

variable "ami" {
    default = "ami-00fd4a75e141e98d5"
}

variable "key_name" {
    default = "key"
}

variable "instance_type" {
    default = "t3.micro"
}

variable "zone_id" {

    default = "XXXXXXXXX"
  
}