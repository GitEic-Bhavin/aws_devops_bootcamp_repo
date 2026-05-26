data "aws_eks_addons_version" "adot_default" {
    addon_name = "adot"
    kubernetes_version = data.terraform_remote_state.eks.outputs.eks_cluster_version
}

data "aws_eks_addon_version" "adot_latest" {
    addon_name = "adot"
    kubernetes_version = data.terraform_remote_state.eks.outputs.eks_cluster_version
    most_recent = true
}

resource "aws_eks_addon" "adot" {
    cluster_name = data.terraform_remote_state.eks.outputs.eks_cluster_id
    addon_name = "adot"
    resolve_conflicts_on_create = "OVERWRITE"
    resolve_conflicts_on_update = "OVERWRITE"
    addon_version = data.aws_eks_addon_version.adot_latest.version

    depends_on = [aws_eks_addon.cert_manager]

    configuration_values = jsonencode({
        manager = {
            resources = {
                limits = {
                    cpu = "200m"
                    memory = "246Mi"
                }
                requests = {
                    cpu = "100m"
                    memory = "64Mi"
                }
            }
        }
        replicaCount = 1
    })

    tags = var.tags
}