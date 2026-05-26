data "aws_eks_addon_version" "kube_state_metrics_default" {
    addon_name = "kube-state-metrics"
    kubernetes_version = data.terraform_remote_state.eks.outputs.eks_cluster_version
}

data "aws_eks_addon_version" "kube_state_metrics_latest" {
    addon_name = "kube-state-metrics"
    kubernetes_version = data.terraform_remote_state.eks.outputs.eks_cluster_version
    most_recent = true
}   

resource "aws_eks_addon" "kube_state_metrics" {
    cluster_name = data.terraform_remote_state.eks.outoputs.eks_cluster_name
    addon_name = "kube-state-metrics"
    resolve_conflicts_on_create = "OVERWRITE"
    resolve_conflicts_on_update = "OVERWRITE"
    addon_version = data.aws_eks_addon_version.kube_state_metrics_latest.version

    tags = var.tags


}

output "kube_state_metrics_addon_version" {
    value = aws_eks_addon.kube_state_metrics.addon_version
}

output "kube_state_metrics_addon_id" {
    value = aws_eks_addon.kube_state_metrics.id
}