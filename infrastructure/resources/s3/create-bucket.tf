# S3 bucket for Terraform State module
resource "random_id" "random_hex" {
  byte_length = 5
}

resource "aws_s3_bucket" "bucket" {
  bucket = "${var.bucket_name}-${var.environment}-${random_id.random_hex.hex}"
  force_destroy = true

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
    ManagedBy   = "Terraform"
  }
}

# encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
# versioning - enable for prod and global-infra; suspended for dev/test
resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = (var.environment == "prod" || var.environment == "global-infra") ? "Enabled" : "Suspended"
  }
}
# block all public access & disable ACLs
resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket                  = aws_s3_bucket.bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
