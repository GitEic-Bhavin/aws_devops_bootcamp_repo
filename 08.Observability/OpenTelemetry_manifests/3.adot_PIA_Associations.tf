# Associate IAM Role to PIA Associations
resource "aws_eks_pod_identity_association" "adot_collector" {
    cluster_name = local.eks_cluster_name
    namespace = "default"
    role_arn = aws_iam_role.adot_collector_role.arn
    service_account = "adot-collector-sa"

    tags = var.tags
}