module "vpc" {
    source = "./modules/vpc"
    aws_region = var.aws_region
    vpc_id = var.vpc_id
    pub_sub_name = var.pub_sub_name
    pvt_sub_name = var.pvt_sub_name
    pub_sub_cidr_block = var.pub_sub_cidr_block
    pvt_sub_cidr_block = var.pvt_sub_cidr_block
    nat_gateway_name = var.nat_gateway_name
    s3_env_name_s3 = var.s3_env_name_s3
    s3_remote_bucket_name = var.s3_remote_bucket_name

  
}