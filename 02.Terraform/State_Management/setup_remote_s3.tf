# Create S3 bucket 
# For state management

resource "random_string" "name" {
    length = 6
    upper = false
    special = false

}

resource "aws_s3_bucket" "s3_bucket" {
    bucket = "bhavindemo-s3-${local.Name}"
    lifecycle {
      prevent_destroy = true
    }
    tags = var.s3_tags
}

resource "aws_s3_bucket_versioning" "tfstate_versioning" {
  bucket = aws_s3_bucket.s3_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate_encyrptions" {
  bucket = aws_s3_bucket.s3_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tfstate_block_public" {
  bucket = aws_s3_bucket.s3_bucket.id
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

output "tfstate_bucket_arn" {
  value = aws_s3_bucket.s3_bucket.arn
}