# Create S3 bucket 

resource "aws_s3_bucket" "s3_bucket" {
    bucket = "bhavindemo-s3-tf-${random_string.name.result}"

    tags = var.s3_tags
}

resource "random_string" "name" {
    length = 6
    upper = false
    special = false

}