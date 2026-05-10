# Create AWS EKS Cluster

# Control Plans

resource "aws_eks_cluster" "main" {
    name = local.eks_cluster_name

    version = var.cluster_version
    role_arn = aws_iam_role.eks_cluster.arn

    vpc_config {

        subnet_ids = data.terraform_remote_state.vpc.outputs.aws_private_sub_id

      # Create eks cluster endpoint as public for testing
        endpoint_public_access = var.cluster_endpoint_public_access

        public_access_cidrs = var.cluster_endpoint_public_access_cidrs
    }

    # Define the Service CIDR range used by Kubernetes service
    kubernetes_network_config {
        service_ipv4_cidr = var.cluster_service_ipv4_cidr
    }

    # enable EKS Control Plan logging for visibility and troubleshootings

    enabled_cluster_log_types = [
        "api",
        "audit",
        "authenticator",
        "controllerManager",
        "scheduler"
    ]

    depends_on = [ 
        aws_iam_role_policy_attachment.eks_cluster_policy,
        aws_iam_role_policy_attachment.eks_vpc_resource_controller
    ]

    tags = var.tags

    access_config {
      authentication_mode = "API_AND_CONFIG_MAP" # We have 3 options: CONFIG_MAP, API, API_AND_CONFIG_MAP
      bootstrap_cluster_creator_admin_permissions = true
    }
}



