data "aws_eks_addon_version" "metrics_server_default" {
    addon_name = "metrics-server"
    kubernetes_version = data.terraform_remote_state.eks.outputs.eks_cluster_versions
}

data "aws_eks_addon_version" "metrics_server_latest" {
    addon_name = "metrics-server"
    kubernetes_version = data.terraform_remote_state.eks.outputs.eks_cluster_versions
}

resource "aws_eks_addon" "metrics_server" {
  cluster_name = data.terraform_remote_state.eks.outputs.eks_cluster_name
  addon_name = "metrics-server"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  addon_version = data.aws_eks_addon_version.metrics_server_latest.version
}

output "metrics_server_eksaddon_default_version" {
  value = data.aws_eks_addon_version.metrics_server_default.version
}

output "metrics_server_eksaddon_latest_version" {
  value = data.aws_eks_addon_version.metrics_server_latest.version
}

output "metrics_server_agent_eksaddon_arn" {
    value = aws_eks_addon.metrics_server.arn
}

output "metrics_server_agent_eksaddon_id" {
  value = aws_eks_addon.metrics_server.id
}