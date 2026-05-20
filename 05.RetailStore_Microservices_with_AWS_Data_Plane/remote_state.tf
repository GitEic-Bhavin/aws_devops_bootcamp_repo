# Define Remote state backend here for VPC

data "terraform_remote_state" "vpc" {
    backend = "s3"

    config = {
        bucket       = "bhavindemo-s3-tfstate-test-qde617"
        key          = "test/terraform.tfstate"
        region       = "ap-south-1"
    }
}

output "vpc_id" {
  value = data.terraform_remote_state.vpc.outputs.vpc_id
}

# output "pvt_sub_id" {
#   value = data.terraform_remote_state.vpc.outputs.pvt_sub_id
# }

output "aws_private_sub_id" {
    value = data.terraform_remote_state.vpc.outputs.aws_private_sub_id
}

output "pub_sub_id" {
  value = data.terraform_remote_state.vpc.outputs.pub_sub_id
}

# Remote state for EKS

data "terraform_remote_state" "eks" {
    backend = "s3"

    config = {
        bucket       = "bhavindemo-s3-tfstate-test-qde617"
        key          = "eks/terraform.tfstate"
        region       = "ap-south-1"
    }
    
}

output "eks_cluster_name" {
  value = data.terraform_remote_state.eks.outputs.eks_cluster_name
}

output "eks_cluster_id" {
  value = data.terraform_remote_state.eks.outputs.eks_cluster_id
}