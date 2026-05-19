data "aws_eks_addon_version" "ebs_csi_default" {
    addon_name = "aws-ebs-csi-driver"
    kubernetes_version = aws_eks_cluster.main.version
}

data "aws_eks_addon_version" "ebs_csi_latest" {
    addon_name = "aws-ebs-csi-driver"
    kubernetes_version = aws_eks_cluster.main.version
    most_recent = true
}

resource "aws_eks_addon" "ebs_csi" {
  depends_on = [ 
    aws_iam_role.ebs_csi_iam_role,
    aws_eks_pod_identity_association.ebs_csi,
    aws_eks_addon.pia,
    aws_eks_node_group.pvt_nodes
   ]

   cluster_name = aws_eks_cluster.main.name
   addon_name = "aws-ebs-csi-driver"
   addon_version = data.aws_eks_addon_version.ebs_csi_latest.version

   service_account_role_arn = aws_iam_role.ebs_csi_iam_role.arn

   resolve_conflicts_on_create = "OVERWRITE"
   resolve_conflicts_on_update = "OVERWRITE"

    tags = var.tags
}

output "ebs_csi_addon_default_version" {
  value = data.aws_eks_addon_version.default.version
}

output "ebs_csi_addon_latest_version" {
  value = data.aws_eks_addon_version.ebs_csi_latest.version
}

output "ebs_csi_addon_id" {
  value = aws_eks_addon.ebs_csi.id
}