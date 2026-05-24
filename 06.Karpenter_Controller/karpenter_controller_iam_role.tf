data "aws_iam_policy_document" "karpenter_controller_assume" {
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

resource "aws_iam_role" "karpenter_controller" {
    name = "${local.eks_cluster_name}-karpenter_role"
    assume_role_policy = data.aws_iam_policy_document.karpenter_controller_assume.json
    tags = var.tags
}

output "karpenter_role_name" {
    value = aws_iam_role.karpenter_controller.name
}

output "karpenter_role_arn" {
    value = aws_iam_role.karpenter_controller.arn
}

