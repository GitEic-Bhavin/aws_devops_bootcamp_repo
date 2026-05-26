resource "aws_iam_policy" "adot_collector_policy" {
    name = "${local.eks_cluster_name}-adot-collector-policy"
    description = "IAM policy for ADOT Collector to send telemetry data to AWS services"
    policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Effect = "Allow",
                Action = [
                    "logs:PutLogEvents",
                    "logs:CreateLogStream",
                    "logs:CreateLogGroup",
                    "logs:DescribeLogStreams",
                    "logs:DescribeLogGroups"
                ],
                # Resource = "*"
                Resource = [
                    "arn:aws:logs:${var.aws_region}:${local.account_id}:log-group:/aws/*",
                    "arn:aws:logs:${var.aws_region}:${local.account_id}:log-group:/aws/*:*"
                ]

            },
            # CloudWatch Logs Permissions (Read - for querying/debugging)
            {
                Effect = "Allow",
                Action = [
                    "logs:GetLogEvents",
                    "logs:FilterLogEvents",
                    "logs:DescribeLogStreams",
                    "logs:DescribeLogGroups"
                ],
                Resource = [
                    "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/*",
                    "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/*:*"
                ]
            },
            
            # CloudWatch Metrics Permissions

            {
                Effect = "Allow",
                Action = [
                    "cloudwatch:PutMetricData"
                ],
                Resource = "*"
            },
            # X-Rey Permissions
            {
                Effect = "Allow",
                Action = [
                    "xray:PutTraceSegments",
                    "xray:PutTelemetryRecords",
                    "xray:GetSamplingRules",
                    "xray:GetSamplingTargets",
                    "xray:GetSamplingStatisticSummaries"
                ],
                Resource = "arn:${local.partition}:xray:${var.aws_region}:${local.account_id}:*"
            },
            # Amazon Managed Prometheus Permissions
            {
                Effect = "Allow",
                Action = [
                    "aps:RemoteWrite",
                    "aps:QueryMetrics",
                    "aps:GetSeries",
                    "aps:GetLabels",
                    "aps:GetMetricMetadata"
                ]
                Resource = aws_prometheus_workspace.amp.arn
            }
        ]
    })

    tags = var.tags
}

# Attach IAM Policy to this IAM Role

resource "aws_iam_role_policy_attachment" "adot_collector" {
    policy_arn = aws_iam_policy.adot_collector_policy.arn
    role = aws_iam_role.adot_collector_role.name
}