# Create Karpenter Node's IAM Role and Policy

data "aws_iam_policy_document" "node_assume" {
    statement {
        actions = ["sts:AssumeRole"]
        principals {
            type = "Service"
            identifiers = ["ec2.amazonaws.com"]
        }
    }
}

resource "aws_iam_role" "karpenter_node" {
    name = "${local.eks_cluster_name}-karpenter_node_role"
    assume_role_policy = data.aws_iam_policy_document.node_assume.json
    tags = var.tags
}

resource "aws_iam_role_policy_attachment" "node_base_policies"  {
    for_each = toset([
        "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
        "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly",
        "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
        "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    ])
        role = aws_iam_role.karpenter_node.name
        policy_arn = each.value

}

output "karpenter_node_role_name" {
    value = aws_iam_role.karpenter_node.name
}

output "karpenter_node_role_arn" {
    value = aws_iam_role.karpenter_node.unique_id
}