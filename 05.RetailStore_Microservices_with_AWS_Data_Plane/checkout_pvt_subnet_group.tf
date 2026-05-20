resource "aws_elasticache_subnet_group" "redis_pvt_sub_group" {
  name = "${local.eks_cluster_name}-pvt-redis-subnet-group"
  subnet_ids = data.terraform_remote_state.vpc.outputs.aws_private_sub_id
}