# Use Locals to define the expressions for reusability

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  public_subnets  = [for k, az in local.azs : cidrsubnet(var.vpc_cidr, var.subnet_newbits, k)]
  private_subnets = [for k, az in local.azs : cidrsubnet(var.vpc_cidr, var.subnet_newbits, k + 10)]
}

output "az_name" {
  value = local.azs
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "subnet_newbits" {
  default = 4
}

output "pub_sub" {
  value = local.public_subnets
}

output "pvt_sub" {
  value = local.private_subnets
}