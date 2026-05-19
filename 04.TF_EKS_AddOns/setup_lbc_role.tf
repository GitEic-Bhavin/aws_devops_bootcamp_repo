# Fetch LBC Policy from git repo

data "http" "lbc_policy" {
    url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json"

    request_headers = {
      Accept = "application/json"
    }
}

# Create LBC Policy using this json LBC files

resource "aws_iam_policy" "lbc_policy" {
  name = "Bhavin_AWSLoadBalancerControllerIAMPolicy_tf_${local.eks_cluster_name}"
  path = "/"
  description = "AWS load balancer controller custom policy"
  policy = data.http.lbc_policy.response_body # Use this policy to create IAM Policy
}

output "lbc_iam_policy_arn" {
  value = aws_iam_policy.lbc_policy.arn
}

# Create LBC IAM Role & Attach this policy

resource "aws_iam_role" "lbc_role" {
  name = "Bhavin_AmazonEKS_LBC_Role_tf_${local.eks_cluster_name}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = var.tags
}

# Attach Policy

resource "aws_iam_role_policy_attachment" "lbc_policy_attach" {
  policy_arn = aws_iam_policy.lbc_policy.arn
  role = aws_iam_role.lbc_role.name
}

output "lbc_iam_role_arn" {
  value = aws_iam_role.lbc_role.arn
}
