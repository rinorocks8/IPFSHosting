# ----------------------------------------------------------------------
# AWS Provider
# ----------------------------------------------------------------------
provider "aws" {
  region     = var.TF_VAR_AWS_DEFAULT_REGION
  access_key = var.TF_VAR_AWS_ACCESS_KEY_ID
  secret_key = var.TF_VAR_AWS_SECRET_ACCESS_KEY
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