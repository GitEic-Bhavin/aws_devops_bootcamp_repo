resource "aws_iam_role"  "ext-dns-role" {
  name = "${local.eks_cluster_name}-ext-dns-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "ext-dns-attach-policy" {
  role = aws_iam_role.ext-dns-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53FullAccess"
}

output "externaldns_role_arn" {
  value = aws_iam_role.ext-dns-role.arn
}

# Associate this role to PIA

resource "aws_eks_pod_identity_association" "ext-dns" {
  cluster_name = aws_eks_cluster.main.name
  namespace = "external-dns"
  service_account = "external-dns"
  role_arn = aws_iam_role.ext-dns-role.arn
}

output "externaldns_pia_associations_id" {
  value = aws_eks_pod_identity_association.ext-dns.id
}