# Create IAM Role with assume role

resource "aws_iam_role" "ebs_csi_iam_role" {
  name = "${local.eks_cluster_name}-ebs-csi-iam-role-tf"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = var.tags
}

# Use AWS Managed policy and attach it to this role

resource "aws_iam_role_policy_attachment" "ebs_csi_policy_attach" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role = aws_iam_role.ebs_csi_iam_role.name
}

output "ebs_csi_iam_role_arn" {
  value = aws_iam_role.ebs_csi_iam_role.arn
}