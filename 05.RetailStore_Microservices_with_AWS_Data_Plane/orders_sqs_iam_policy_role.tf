resource "aws_iam_policy" "orders_sqs_policy" {
    name = "${local.eks_cluster_name}-sqs-policy-pia"
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Sid = "OrdersSQSAccess"
                Effect = "Allow"
                Action = [
                    "sqs:SendMessage",
                    "sqs:ReceiveMessage",
                    "sqs:DeleteMessage",
                    "sqs:GetQueueAttributes",
                    "sqs:GetQueueUrl",
                    "sqs:ListQueues",
                    "sqs:PurgeQueue"
                ]
                Resource = aws_sqs_queue.orders_sqs.arn
            }
        ]
    })
}

# Attach this Policy to Role and then Associate to PIA

resource "aws_iam_role_policy_attachment" "orders_sqs_role_attachment" {
    policy_arn = aws_iam_policy.orders_sqs_policy.arn
    role = aws_iam_role.orders_psql_secrets.name
}

output "orders_sqs_policy_arn" {
    value = aws_iam_policy.orders_sqs_policy.arn
}