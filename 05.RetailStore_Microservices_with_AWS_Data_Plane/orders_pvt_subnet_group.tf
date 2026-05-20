# Create pvt subnet groups for RDS PSQL.

resource "aws_db_subnet_group" "psql_subnet_group" {
    name = "${local.eks_cluster_name}-psql-subnet-group"
    subnet_ids = data.terraform_remote_state.vpc.outputs.aws_private_sub_id

    tags = var.tags
}