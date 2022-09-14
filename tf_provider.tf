# ----------------------------------------------------------------------
# AWS Provider
# ----------------------------------------------------------------------
provider "aws" {
  region     = var.aws_region
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
}

# ----------------------------------------------------------------------
# Terraform
# ----------------------------------------------------------------------
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.30.0"
    }
  }

  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "rinorocks8"

    workspaces {
      name = "IPFSHosting"
    }
  }
}