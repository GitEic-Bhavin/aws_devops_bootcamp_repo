resource "aws_eks_pod_identity_association" "catalog_secrets_manager" {
  cluster_name = data.terraform_remote_state.eks.outputs.eks_cluster_name
  namespace = "default"
  role_arn = aws_iam_role.catalog-secret-csi-role.arn
  service_account = "catalog-sa"
}

output "catalog_sa_pod_identity_association_arn" {
  value = aws_eks_pod_identity_association.catalog_secrets_manager.association_arn
}