terraform {
  required_version = ">= 1.12.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
    #  mysql = {
    #   source  = "petoju/mysql"
    #   version = "~> 3.0"
    # }

    # postgresql = {
    #   source  = "cyrilgdn/postgresql"
    #   version = "~> 1.26"
    # }
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

# # Use existing MySQL RDS

# provider "mysql" {

#   endpoint = "${data.aws_db_instance.catalog_rds.address}:3306"

#   username = local.retailstore_secret_json.username
#   password = local.retailstore_secret_json.password

#   tls = true
# }

# # Use existing RDS PSQL DB 

# provider "postgresql" {

#   host = data.aws_db_instance.psql.address
#   port = 5432
#   database = "ordersdb"
#   username = local.retailstore_secret_json.username
#   password = local.retailstore_secret_json.password
#   sslmode = "require"
# }

data "aws_caller_identity" "current" {}

# output "account_id" {
#   value = data.aws_caller_identity.current.account_id
# }