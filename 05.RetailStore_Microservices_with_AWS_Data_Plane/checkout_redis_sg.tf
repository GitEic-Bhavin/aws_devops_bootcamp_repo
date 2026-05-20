resource "aws_security_group" "redis-sg" {
  name = "${local.eks_cluster_name}-redis-SG"
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    from_port =  6379
    to_port = 6379
    protocol = "tcp"
    security_groups = [data.terraform_remote_state.eks.outputs.eks_cluster_security_group_id]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}