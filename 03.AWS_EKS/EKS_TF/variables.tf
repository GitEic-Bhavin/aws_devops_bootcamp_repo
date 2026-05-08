variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "env_name" {
  description = "Environment name used in resource names and tags"
  type        = string
  default     = "dev"
}

# EKS Cluster Configurations Vars

variable "cluster_name" {
  type    = string
  default = "eksdemo_bhavin"
}

variable "cluster_version" {
  type    = string
  default = null
}

variable "cluster_service_ipv4_cidr" {
  description = "Its a CIDRs to assign IPs to your pods and services from this CIDR range only.  If you didn't speify EKS and kubernetes will take default by itself like 10.0.0.0/16"

  type    = string
  default = null
}


variable "cluster_endpoint_public_access" {
  type    = bool
  default = true
}

variable "cluster_endpoint_public_access_cidrs" {
  type = list(string)
  default = ["115.112.142.32/29", "182.76.141.104/29", "14.97.73.248/32"]

}

# Common Tags

variable "tags" {
  type = map(string)
  default = {
    Department   = "PES_IA"
    Owner        = "bhavin.bhavsar@einfochips.com"
    End_Date     = "4 May 2026"
    Project_Name = "EIC_Internal"
    DM           = "Sachin.Shah1@einfochips.com"

  }
}

variable "environment_name" {
  type = string
  default = "test"
}


