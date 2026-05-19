# Fetch PIA AddOns First

data "aws_eks_addon_version" "default" {
    addon_name = "eks-pod-identity-agent"
    kubernetes_version = aws_eks_cluster.main.version
}

data "aws_eks_addon_version" "latest" {
    addon_name = "eks-pod-identity-agent"
    kubernetes_version = aws_eks_cluster.main.version
    most_recent = true
}

# Create Install AddOns PIA

resource "aws_eks_addon" "pia" {
  cluster_name = aws_eks_cluster.main.id
  addon_name = "eks-pod-identity-agent"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  addon_version = data.aws_eks_addon_version.latest.version
}

output "pod_identity_agent_eskaddons_default_versions" {
  value = data.aws_eks_addon_version.default.version
}

output "pod_identity_agent_eskaddons_latest_versions" {
  value = data.aws_eks_addon_version.latest.version
}

output "pia_eksaddons_arn" {
  value = aws_eks_addon.pia.arn
}

output "pia_eksaddons_id" {
  value = aws_eks_addon.pia.id
}