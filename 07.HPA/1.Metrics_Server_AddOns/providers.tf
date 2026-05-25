terraform {
  required_version = ">= 1.5.7"

  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = ">= 6.20"
    }
  }

  backend "s3" {
    bucket = "bhavindemo-s3-tfstate-test-qde617"
    key = "metrics-server/terraform.tfstate"
    region = "ap-south-1"
    encrypt = true
    use_lockfile = true
  }
}

provider "aws" {
  region = "ap-south-1"
}

data "terraform_remote_state" "eks" {
    backend = "s3"

    config = {
        bucket = "bhavindemo-s3-tfstate-test-qde617"
        key = "eks/terraform.tfstate"
        region = "ap-south-1"
    }
}


output "eks_cluster_name" {
    value = data.terraform_remote_state.eks.outputs.eks_cluster_name
}

output "eks_cluster_id" { 
  value = data.terraform_remote_state.eks.outputs.eks_cluster_id
}

# output "eks_cluster_versions" {
#   value = data.terraform_remote_state.eks.outputs.eks_cluster_versions
# }