# Create EKS Private Node Group

resource "aws_eks_node_group" "pvt_nodes" {
    
    cluster_name = aws_eks_cluster.main.name

    node_group_name = "${local.eks_cluster_name}-private-nodegroup"

    node_role_arn = aws_iam_role.eks_nodegroup_role.arn

    # Private Subnet ID # Add another pvt subnet id is required
    subnet_ids = data.terraform_remote_state.vpc.outputs.aws_private_sub_id
    
    instance_types = var.node_instance_types

    capacity_type = var.node_capacity_type

    # ami_type = "AL2023_x86_64_STANDARD"
    ami_type = "AL2_x86_64"

    disk_size = var.node_root_disk_size

    # Configure auto-scaling limits and defaults
    scaling_config {
      desired_size = 2

      min_size = 1

      max_size = 3
    }

    # set the max percentage of nodes that can be unavailable during update
    update_config {
      max_unavailable_percentage = 33 # So, m
    }

    # Apply labels to each EC2 instance for easier schedule
    force_update_version = true

    # Apply force node group update on those Nodes which has this labels
    labels = {
      "env" = var.environment_name
    }

    # Assign required tags for worker nodes
    tags = merge(
        var.tags, { Name = "${local.eks_cluster_name}-private_nodeGroup"
        Environment = var.environment_name
    })

    depends_on = [ 
        aws_iam_role_policy_attachment.eks_worker_node_policy,
        aws_iam_role_policy_attachment.eks_ecr_policy,
        aws_iam_role_policy_attachment.eks_vpc_cni_policy
     ]
}
