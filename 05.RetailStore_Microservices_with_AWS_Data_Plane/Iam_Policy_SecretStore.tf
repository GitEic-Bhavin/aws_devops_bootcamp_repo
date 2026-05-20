resource "aws_iam_policy" "secrets_policy" {
  name = "${local.eks_cluster_name}-secrets-manager-policy-tf"
  path = "/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Effect = "Allow"
            Action = [
                "secretsmanager:GetSecretValue",
                "secretsmanager:DescribeSecret"
            ]
            Resource = "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:Bhavin_EKS_catalog-db-secret*"
        }
    ]
  })
}

output "retailstore_db_secret_policy_arn" {
  value = aws_iam_policy.secrets_policy.arn
}