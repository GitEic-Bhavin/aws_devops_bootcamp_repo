data "aws_iam_policy_document" "adot_collector_assume" {
    statement {
        sid = "PodIdentity"
        actions = [
            "sts:AssumeRole",
            "sts:TagSession"
        ]

        principals {
            type = "Service"
            identifiers = ["pods.eks.amazonaws.com"]
        }
    }
}

resource "aws_iam_role" "adot_collector_role" {
    name = "${local.eks_cluster_name}-adot-collector-role"
    assume_role_policy = data.aws_iam_policy_document.adot_collector_assume.json
}

output "adot_collector_role_arn" {
    value = aws_iam_role.adot_collector_role.arn
}

####

