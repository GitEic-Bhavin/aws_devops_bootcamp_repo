resource "aws_iam_role" "amg_iam_role" {
    name = "${local.eks_cluster_name}-amg-iam-role"
    assume_role_policy = jasonencode ({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Principal = {
                    Service = "grafana.amazonaws.com"
                }
                Action = "sts:AssumeRole"
            }
        ]
    })

    tags = var.tags
}

# Attach Policy of Prometheus Access

resource "aws_iam_role_policy_attachment" "amg_prometheus_attach" {
    role = aws_iam_role.amg_iam_role.name
    policy_arn = aws_iam_policy.amg_prometheus_policy.arn
}

# Attach Policy 2 : SNS Access

resource "aws_iam_role_policy_attachment" "amg_sns_attachment" {
    role = aws_iam_role.amg_iam_role.name
    policy_arn = aws_iam_policy.amg_sns_policy.arn
}

# Attach AWSXrayReadOnlyAccess Policy

resource "aws_iam_role_policy_attachment" "amg_xray_readonly_attachment" {
    role = aws_iam_role.amg_iam_role.name
    policy_arn = data.aws_iam_policy.xray_readonly.arn
}

# Output

output "amg_iam_role_arn" {
    value = aws_iam_role.amg_iam_role.arn
}

output "amg_iam_role_name" {
    value = aws_iam_role.amg_iam_role.name
}

