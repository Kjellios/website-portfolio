# === Main site bucket ===
resource "aws_s3_bucket" "main_site" {
  bucket = "kjellhysjulien.com"

  tags = {
    Project = "portfolio-website"
    Env     = "prod"
  }
}

resource "aws_s3_bucket_public_access_block" "main_site" {
  bucket = aws_s3_bucket.main_site.id

  block_public_acls       = true
  block_public_policy     = false # Allow public policy attachment
  ignore_public_acls      = true
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "main_site_public_read" {
  bucket = aws_s3_bucket.main_site.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.main_site.arn}/*"
      }
    ]
  })
}

resource "aws_s3_bucket_website_configuration" "main_site" {
  bucket = aws_s3_bucket.main_site.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# === Redirect bucket (www -> root domain) ===
resource "aws_s3_bucket" "www_redirect" {
  bucket = "www.kjellhysjulien.com"

  tags = {
    Project = "portfolio-website"
    Env     = "prod"
  }
}

resource "aws_s3_bucket_website_configuration" "www_redirect" {
  bucket = aws_s3_bucket.www_redirect.id

  redirect_all_requests_to {
    host_name = "kjellhysjulien.com"
    protocol  = "https"
  }
}

# === Logging bucket (used for CloudFront access logs) ===
resource "aws_s3_bucket" "logs" {
  bucket = "logs.kjellhysjulien.com"

  tags = {
    Project = "portfolio-website"
    Env     = "prod"
  }
}

resource "aws_s3_bucket_policy" "log_bucket_policy" {
  bucket = aws_s3_bucket.logs.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "CloudFrontLogsWrite",
        Effect = "Allow",
        Principal = {
          Service = "cloudfront.amazonaws.com"
        },
        Action   = "s3:PutObject",
        Resource = "${aws_s3_bucket.logs.arn}/cloudfront/*",
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.website_cdn.arn
          }
        }
      }
    ]
  })
}
