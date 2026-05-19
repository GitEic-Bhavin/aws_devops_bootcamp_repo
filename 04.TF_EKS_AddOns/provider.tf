# Eks cluster Auth
data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.main.id
}

terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }

  # Setup S3 Remote Backend
  backend "s3" {
    bucket       = "bhavindemo-s3-tfstate-test-qde617"
    key          = "eks/terraform.tfstate"
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

provider "kubernetes" {
  # cluster_ca_certificate = aws_eks_cluster.main.
  token = data.aws_eks_cluster_auth.cluster.token
  host = aws_eks_cluster.main.endpoint
  # cluster_ca_certificate = base64decode(aws_eks_cluster.main.certificate_authority[0].data)
  cluster_ca_certificate = base64decode(aws_eks_cluster.main.certificate_authority[0].data)

}

# Helm Provider

provider "helm" {
  kubernetes = {
    host = aws_eks_cluster.main.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.main.certificate_authority[0].data)
    token = data.aws_eks_cluster_auth.cluster.token
  }
}

output "eks_certificate_auth" {
  value = aws_eks_cluster.main.certificate_authority
}