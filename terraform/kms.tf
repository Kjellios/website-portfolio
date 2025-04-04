# kms.tf for S3 encryption

resource "aws_kms_key" "s3_encryption" {
  description             = "KMS key for S3 bucket encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = {
    Name    = "s3-encryption-key"
    Project = "portfolio-website"
    Env     = "prod"
  }
}
