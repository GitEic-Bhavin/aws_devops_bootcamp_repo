locals {
    environment = var.environment_name
    eks_cluster_name = "bhavindemo-eks-${var.environment_name}"
}