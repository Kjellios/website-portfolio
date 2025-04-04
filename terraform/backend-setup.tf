# This sets up an S3 bucket with versioning and encryption, and a DynamoDB table with on-demand billing and tagging for locking.

# Terraform State Storage Bucket
resource "aws_s3_bucket" "terraform_state" {
  bucket        = "terraform-state-kjell"
  force_destroy = true

  tags = {
    Name        = "Terraform State Bucket"
    Environment = "prod"
    Project     = "portfolio-website"
  }
}

resource "aws_s3_bucket_versioning" "state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state_encryption" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# DynamoDB Table for State Locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform Lock Table"
    Environment = "prod"
    Project     = "portfolio-website"
  }
}
