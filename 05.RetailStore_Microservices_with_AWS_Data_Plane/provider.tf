terraform {
  required_version = ">= 1.12.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }

  # Setup S3 Remote Backend
  backend "s3" {
    bucket       = "bhavindemo-s3-tfstate-test-qde617"
    key          = "retail-persistent-endpoints/dev/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true

  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    
    tags = {
        Department   = "PES_IA"
        Owner        = "bhavin.bhavsar@einfochips.com"
        End_Date     = "4 May 2026"
        Project_Name = "EIC_Internal"
        DM           = "Sachin.Shah1@einfochips.com"

      }

    }
}

data "aws_caller_identity" "current" {}

# output "account_id" {
#   value = data.aws_caller_identity.current.account_id
# }