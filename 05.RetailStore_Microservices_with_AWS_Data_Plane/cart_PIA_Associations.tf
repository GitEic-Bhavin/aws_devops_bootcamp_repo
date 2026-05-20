resource "aws_eks_pod_identity_association" "cart_pia" {
  cluster_name = data.terraform_remote_state.eks.outputs.eks_cluster_name
  namespace = "default"
  service_account = "carts-sa"
  role_arn = aws_iam_role.cart_dynamodb_role.arn
}

output "cart_dynamodb_pod_identity_associations_arn" {
  value = aws_eks_pod_identity_association.cart_pia.role_arn
}