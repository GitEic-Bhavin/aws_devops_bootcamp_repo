# Amazon Grafana Prometheus Access Policy

resource "aws_iam_policy" "amg_prometheus_policy" {
    name = "${local.eks_cluster_name}-amg-prometheus-policy"

    policy = jsonencode ({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "aps:ListWorkspaces",
                    "aps:GetWorkspace",
                    "aps:DescribeWorkspace",
                    "aps:QueryMetrics",
                    "aps:GetSeries",
                    "aps:GetLabels",
                    "aps:GetMetricMetadata"
                ]
                Resource = "*"
            }
        ]
    })

    tags = var.tags
}

# Amazon Grafana SNS Policy

resource "aws_iam_policy" "amg_sns_policy" {
    name = "${local.eks_cluster_name}-amg-sns-policy"

    policy = jsonencode ({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "sns:Publish"
                ]
                Resource = "arn:aws:sns:${local.account_id}:grafana*"
            }
        ]
    })

    tags = var.tags
}

data "aws_iam_policy" "xray_readonly" {
    arn = "arn:aws:iam:aws:policy/AWSXrayReadOnlyAccess"
}