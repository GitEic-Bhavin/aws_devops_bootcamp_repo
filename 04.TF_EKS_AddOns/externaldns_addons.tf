data "aws_eks_addon_version" "extdns_latest"  {
    addon_name = "external-dns"
    kubernetes_version = aws_eks_cluster.main.version
    most_recent = true
}

resource "aws_eks_addon" "extdns" {
  depends_on = [ 
    aws_iam_role.ext-dns-role,
    aws_eks_pod_identity_association.ext-dns,
    aws_eks_addon.pia,
    aws_eks_node_group.pvt_nodes
   ]
   
   cluster_name = aws_eks_cluster.main.name
   addon_name = "external-dns"
   addon_version = data.aws_eks_addon_version.extdns_latest.version

   resolve_conflicts_on_create = "OVERWRITE"
   resolve_conflicts_on_update = "OVERWRITE"

   service_account_role_arn = aws_iam_role.ext-dns-role.arn

   tags = var.tags
}

output "extdns_addon_version" {
  value = aws_eks_addon.extdns.addon_version
}

output "extdns_addon_arn" {
  value = aws_eks_addon.extdns.arn
}

output "extdns_addon_id" {
  value = aws_eks_addon.extdns.id
}