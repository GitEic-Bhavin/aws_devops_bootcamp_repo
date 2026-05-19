resource "aws_eks_pod_identity_association" "ebs_csi" {
  cluster_name = aws_eks_cluster.main.name
  namespace = "kube-system"
  role_arn = aws_iam_role.ebs_csi_iam_role.arn
  service_account = "ebs-csi-controller-sa"
}

output "ebs_csi_pod_identity_association_arn" {
  value = aws_eks_pod_identity_association.ebs_csi.association_arn
}