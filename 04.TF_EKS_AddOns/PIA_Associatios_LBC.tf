# Pod Identity Associations for LBC.action 

resource "aws_eks_pod_identity_association" "lbc" {
  cluster_name = aws_eks_cluster.main.name
  namespace = "kube-system"
  role_arn = aws_iam_role.lbc_role.arn
  service_account = "aws-load-balancer-controller-sa"
}

output "lbc_poad_identity_association_arn" {
    value = aws_eks_pod_identity_association.lbc.association_arn
}