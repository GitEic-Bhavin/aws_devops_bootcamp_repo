data "aws_eks_cluster_auth" "cluster" {
    name = data.terraform_remote_state.eks.outputs.eks_cluster_name
}

data "aws_eks_cluster" "cluster" {
    name = data.terraform_remote_state.eks.outputs.eks_cluster_name
}

terraform {
    required_version = ">= 1.5.7"

    required_providers {
        kubernetes = {
            source  = "hashicorp/kubernetes"
            version = ">= 2.28"
        }
        aws = {
            source  = "hashicorp/aws"
            version = ">= 6.20"
        }
        helm = {
            source  = "hashicorp/helm"
            version = "~>= 3.0"
        }
    }

    backend "s3" {
        bucket = "bhavindemo-s3-tfstate-test-qde617"
        key = "opentelemetry/terraform.tfstate"
        region = "ap-south-1"
        encrypt = true
        use_lockfile = true
    }

}

provider "aws" {

    region = "ap-south-1"
}

# provider "kubernetes" {
#     host                   = data.aws_eks_cluster_auth.cluster.endpoint
#     # cluster_ca_certificate = base64decode(data.aws_eks_cluster_auth.cluster.certificate_authority[0].data)
#     cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.eks_cluster_ca_cert)
#     token                  = data.aws_eks_cluster_auth.cluster.token
# }

# provider "helm" {
#     kubernetes {
#         host                   = data.aws_eks_cluster_auth.cluster.endpoint
#         cluster_ca_certificate = base64decode(data.aws_eks_cluster_auth.cluster.certificate_authority[0].data)
#         token                  = data.aws_eks_cluster_auth.cluster.token
#     }
# }

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