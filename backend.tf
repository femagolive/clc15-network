terraform {
  backend "s3" {
    bucket = "clc15-felipe-magalhaes-terraform"
    key    = "network/terraform.tfstate"
    region = "us-east-1"
  }
}