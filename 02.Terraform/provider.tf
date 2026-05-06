# Provider.tf is uses to define which terraform provider you want to use to provision and manage resources.
# For instance, aws, gcp, azure

provider "aws" {
  region = "ap-south-1"

}

# terraform block

# Terraform block used to define the required_versions of terraform cli versions and terraform providers versions

terraform {
  required_version = ">=1.0.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 6.0"
    }

    random = {
        source = "hashicorp/random"
        version = "~>3.0"
    }

  }
}