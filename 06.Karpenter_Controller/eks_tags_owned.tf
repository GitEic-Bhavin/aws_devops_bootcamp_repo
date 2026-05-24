# resource "aws_ec2_tag" "eks_subnet_tag_public_elb"  {
#     count = length(data.terraform_remote_state.vpc.outputs.pub_sub_id)
#     resource_id = data.terraform_remote_state.vpc.outputs.pub_sub_id[count.index]
#     key = "kubernetes.io/role/elb"
#     value = "1"
# }

# resource "aws_ec2_tag" "eks_subnet_tag_public_cluster" {
#     count = length(data.terraform_remote_state.vpc.outputs.pub_sub_id)
#     resource_id = data.terraform_remote_state.vpc.outputs.pub_sub_id[count.index]
#     key = "kubernetes.io/cluster/${local.eks_cluster_name}"
#     value = "owned"
# }

# # Private Subnet Tags for EKS Internal LB

# resource "aws_ec2_tag" "eks_subnet_tag_private_elb" {
#     count = length(data.terraform_remote_state.vpc.outputs.aws_private_sub_id)
#     resource_id = data.terraform_remote_state.vpc.outputs.aws_private_sub_id[count.index]
#     key = "kubernetes.io/role/internal-elb"
#     value = "1"
# }

# resource "aws_ec2_tag" "eks_subnet_tag_private_cluster" {
#     count = length(data.terraform_remote_state.vpc.outputs.aws_private_sub_id)
#     resource_id = data.terraform_remote_state.vpc.outputs.aws_private_sub_id[count.index]
#     key = "kubernetes.io/cluster/${local.eks_cluster_name}"
#     value = "owned"
# }
