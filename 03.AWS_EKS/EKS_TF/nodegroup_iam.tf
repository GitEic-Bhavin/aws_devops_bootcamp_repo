# IAM Role for EKS Node Group Worker Node to communicate with Master Node and other AWS Services Communications.

# AWS Policy will assumed by this Nodegroup 

resource "aws_iam_role" "eks_nodegroup_role" {
    name = "${local.eks_cluster_name}-eks-nodegroup-role"

    # Trust policy: To assume this role by nodegroup
    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [{
            Action = "sts:AssumeRole",
            Effect = "Allow",
            Principal = {
                Service = "ec2.amazonaws.com"
            }
        }]
    })

    tags = var.tags
}
# Assign AmazonEKSWorkerNodePolicy to worker nodes

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
    role = aws_iam_role.eks_nodegroup_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

# Assign VPC CNI Policy to worker nodes

resource "aws_iam_role_policy_attachment" "eks_vpc_cni_policy" {
    role = aws_iam_role.eks_nodegroup_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# Assign ECR Read Only Policy to pull docker images from ECR

resource "aws_iam_role_policy_attachment" "eks_ecr_policy" {
    role = aws_iam_role.eks_nodegroup_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}