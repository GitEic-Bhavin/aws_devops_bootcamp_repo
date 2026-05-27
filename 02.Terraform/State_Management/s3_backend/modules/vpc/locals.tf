# locals {
#   azs             = slice(data.aws_availability_zones.available.names, 0, 2)
# #   public_subnets  = [for k, az in local.azs : cidrsubnet(var.vpc_cidr, var.subnet_newbits, k)]
#   private_subnets = [for k, az in local.azs : cidrsubnet(var.vpc_cidr, var.subnet_newbits, k + 10)]
# }

# data "aws_availability_zones" "available" {
#   state = "available"
# }

locals {
  azs             = ["ap-south-1a", "ap-south-1b"]
  # Here is where you define the specific private ranges you wanted
  private_subnets = ["10.0.111.0/24", "10.0.211.0/24"] 
  public_subnets = ["10.0.11.0/24", "10.0.32.0/24"]
  
  pub_rt_name     = "BhavinBhavsar-01-pub-rt"
  priv_rt_name    = "BhavinBhavsar-01-priv-rt"
}