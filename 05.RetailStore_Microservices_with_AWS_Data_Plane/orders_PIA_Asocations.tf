resource "aws_eks_pod_identity_association" "orders_psql" {
  cluster_name = data.terraform_remote_state.eks.outputs.eks_cluster_name
  namespace = "default"
  service_account = "orders-sa"
  role_arn = aws_iam_role.orders_psql_secrets.arn
}

output "orders_psql_sa_pia_associations_arn" {
  value = aws_eks_pod_identity_association.orders_psql.association_arn
}