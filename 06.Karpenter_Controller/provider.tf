data "aws_eks_cluster_auth" "cluster" {
  name = data.terraform_remote_state.eks.outputs.eks_cluster_name
}

# Eks cluster Auth
terraform {
  required_version = ">= 1.5.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.20"
    }
    helm = {
      source = "hashicorp/helm"
      version = "~> 3.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "= 2.28"
    }
  }

  # Setup S3 Remote Backend
  backend "s3" {
    bucket       = "bhavindemo-s3-tfstate-test-qde617"
    key          = "karpenter/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true

  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    
    tags = {
        Department   = "PES_IA"
        Owner        = "bhavin.bhavsar@einfochips.com"
        End_Date     = "4 May 2026"
        Project_Name = "EIC_Internal"
        DM           = "Sachin.Shah1@einfochips.com"

      }

    }
}

provider "helm" {
  kubernetes = {
    host = data.terraform_remote_state.eks.outputs.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.eks_cluster_certificate_authority_data)
    token = data.aws_eks_cluster_auth.cluster.token
  }
}

provider "kubernetes" {
  host = data.terraform_remote_state.eks.outputs.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.eks_cluster_certificate_authority_data)
  token = data.aws_eks_cluster_auth.cluster.token
  
}