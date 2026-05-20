# Create ElasticCache Redis Cluster in the Private Subnet

resource "aws_elasticache_cluster" "redis_cluster" {
    cluster_id   = "${local.eks_cluster_name}-pvt-redis-cluster-checkout"
    engine = var.checkout_redis_engine
    engine_version = var.checkout_redis_engine_version
    node_type = var.checkout_redis_node_type
    num_cache_nodes = var.checkout_redis_num_cache_nodes

    port = 6379

    subnet_group_name = aws_elasticache_subnet_group.redis_pvt_sub_group.name
    security_group_ids = [aws_security_group.redis-sg.id]
    parameter_group_name = "default.redis7"

    tags = var.tags

}

output "checkout_redis_endpoint" {
  value = aws_elasticache_cluster.redis_cluster.cache_nodes[0].address
}