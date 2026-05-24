# Nodes will created by Karpenter Controller
# This Nodes will join to EKS Cluster
# To allow this Pod Identity Agent andPIA Associations is not enough.
# PIA Associations is just use for allow pods to assume role to perform tasks with another services only.

# Here Access Entry will work.

# So whatever a reaql iam user can do with cluster like join cluster execute kubectl to create , delte, update resources.

# That can do by Nodes itself.

resource "aws_eks_access_entry"  "karpenter_node_access" {
    depends_on = [ data.terraform_remote_state.eks ]
    cluster_name = data.terraform_remote_state.eks.outputs.eks_cluster_name
    principal_arn = aws_iam_role.karpenter_node.arn
    type = "EC2_LINUX"
}