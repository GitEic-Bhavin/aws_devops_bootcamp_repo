variable "environment_name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "aws_region" {
  type = string
  default = "ap-south-1"
}

variable "helm_karpenter_chart" {
  type = string
}
variable "helm_release_name_karpenter" {
  type = string
}
variable "karpenter_helm_repo" {
  type = string
}
variable "karpenter_helm_version" {
  type = string
}