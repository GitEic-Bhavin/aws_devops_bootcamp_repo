terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }

  # Setup S3 Remote Backend
  backend "s3" {
    bucket       = "bhavindemo-s3-tfstate-test-qde617"
    key          = "test/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true

  }
}

provider "aws" {
  region = var.aws_region
}