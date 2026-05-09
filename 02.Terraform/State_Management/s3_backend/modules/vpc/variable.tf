variable "aws_region" {
  type = string
}

variable "s3_remote_bucket_name" {
  type = string
}

variable "s3_env_name_s3" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "pub_sub_cidr_block" {
  type = string
}

variable "pvt_sub_cidr_block" {
  type = string
}

variable "nat_gateway_name" {
  type = list(string)
}

variable "pub_sub_name" {
  type = map(string)
}

variable "pvt_sub_name" {
  type = map(string)
}

variable "vpc_cidr" {
  type = string
}

variable "subnet_newbits" {
  
}

variable "environment_name" {
  default = "test"
}

variable "tags" {
  type = map(string)
}