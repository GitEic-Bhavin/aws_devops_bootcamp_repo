data "terraform_remote_state" "vpc" {
    backend = "s3"

    config = {
        bucket = "bhavindemo-s3-tfstate-test-qde617"
        key    = "vpc/terraform.tfstate"
        region = "var.aws_region"
    }
}

output "vpc_id" {
  value = data.terraform_remote_state.vpc.outputs.vpc_id
}


output "aws_private_sub_id" {
    value = data.terraform_remote_state.vpc.outputs.aws_private_sub_id
}

output "pub_sub_id" {
  value = data.terraform_remote_state.vpc.outputs.pub_sub_id
}


data "terraform_remote_state" "eks" {
    backend = "s3"

    config = {
        bucket = "bhavindemo-s3-tfstate-test-qde617"
        key    = "eks/terraform.tfstate"
        region = "var.aws_region"
    }
}

output "eks_cluster_name" {
  value = data.terraform_remote_state.eks.outputs.eks_cluster_name
}

output "eks_cluster_id" {
    value = data.terraform_remote_state.eks.outputs.eks_cluster_id
}