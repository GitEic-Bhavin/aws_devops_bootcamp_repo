data "aws_caller_identity" "current" {}

data "aws_region" "currnet" {}

data "aws_partition" "current" {}

locals {
    partition = data.aws_partition.current.partition
    vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
    eks_cluster_name = data.terraform_remote_state.eks.outputs.eks_cluster_name

    account_id = data.aws_caller_identity.current.account_id
    
}