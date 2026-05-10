output "eks_cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "eks_cluster_id" {
  value = aws_eks_cluster.main.id
}

output "eks_cluster_versions" {
  value = aws_eks_cluster.main.version
}

output "eks_cluster_name" {
  value = aws_eks_cluster.main.name
}

output "eks_cluster_certificate_authority_data"  {
    value = aws_eks_cluster.main.certificate_authority[0].data
    description = "Base64 encoded CA certificate for kubectl config"

}

output "private_node_group_name" {
    value = aws_eks_node_group.pvt_nodes.node_group_name
}

output "eks_node_instance_role_arn" {
    value = aws_iam_role.eks_nodegroup_role.arn
}

output "configure_kubectl_context" {
    value = "aws eks --region ${var.aws_region} update-kubeconfig --name ${local.eks_cluster_name}"
}