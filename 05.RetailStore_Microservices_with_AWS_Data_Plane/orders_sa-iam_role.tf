# Create IAM Role for Service Account of PSQL Access for Orders Pods
resource "aws_iam_role" "orders_psql_secrets" {
  name = "${local.eks_cluster_name}-orders-psql-secrets_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = var.tags

}

# Attach IAM Policy to Role which is used by PIA Associations and SA

resource "aws_iam_role_policy_attachment" "orders_psql_secrets_attachment" {
  policy_arn = aws_iam_policy.secrets_policy.arn
  role = aws_iam_role.orders_psql_secrets.name
}

output "orders_postgresql_sa_secrets_role_arn" {
  value = aws_iam_role.orders_psql_secrets.arn
}