data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
    environment = var.environment_name
    eks_cluster_name = data.terraform_remote_state.eks.outputs.eks_cluster_name
}

