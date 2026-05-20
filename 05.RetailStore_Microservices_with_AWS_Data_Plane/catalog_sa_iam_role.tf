resource "aws_iam_role" "catalog-secret-csi-role" {
  name = "${local.eks_cluster_name}-catalog-secret-csi-driver-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = var.tags

}

# Attach IAM Policy to this Role

resource "aws_iam_role_policy_attachment" "catalog_secret_policy_attach" { 
  policy_arn = aws_iam_policy.secrets_policy.arn
  role = aws_iam_role.catalog-secret-csi-role.name
}

output "catalog_sa_getsecrets_role_arn" {
  value = aws_iam_role.catalog-secret-csi-role.arn
}