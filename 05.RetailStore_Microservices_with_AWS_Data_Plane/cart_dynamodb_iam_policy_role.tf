resource "aws_iam_policy" "cart_policy" {
  name = "${local.eks_cluster_name}-cart-dynamodb_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Effect = "Allow"
            Action = [
                "dynamodb:CreateTable",
                "dynamodb:DeleteTable",
                "dynamodb:DescribeTable",
                "dynamodb:UpdateTable",
                "dynamodb:PutItem",
                "dynamodb:GetItem",
                "dynamodb:DeleteItem",
                "dynamodb:Query",
                "dynamodb:Scan",
                "dynamodb:UpdateItem",
                "dynamodb:BatchGetItem",
                "dynamodb:BatchWriteItem",
                "dynamodb:DescribeTimeToLive",
                "dynamodb:ListTables",
                "dynamodb:ListTagsOfResource"
            ]
            
            Resource = "*"  # Full access to all DynamoDB resources in all regions

        }
    ]
  })
}

# Create IAM Role for PIA

resource "aws_iam_role" "cart_dynamodb_role" {
  name = "${local.eks_cluster_name}-cart-dynamodb_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = var.tags
}

# Attach this Policy to This Role for PIA

resource "aws_iam_role_policy_attachment" "cart_pia_role_attachement" {
  policy_arn = aws_iam_policy.cart_policy.arn
  role = aws_iam_role.cart_dynamodb_role.name
}

output "cart_policy_arn" {
    value = aws_iam_policy.cart_policy.arn
}

output "cart_role_arn" {
  value = aws_iam_role.cart_dynamodb_role.arn
}