# Output is used to publish output of resource and usable by any of modules.

# output "s3_bucket_name" {
#     value = aws_s3_bucket.s3_bucket.bucket
# }

output "vpc_id" {
  value = module.vpc.vpc_id
}

# output "pvt_sub_id" {
#   value = module.vpc.aws_private_sub_id
# }

output "pub_sub_id" {
  value = module.vpc.aws_public_sub_id
}

output "aws_private_sub_id" {
  value = module.vpc.aws_private_sub_id
}