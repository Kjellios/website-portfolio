# === AWS Provider ===
provider "aws" {
  region = "us-east-1"
}

# === KMS Key for S3 encryption ===
resource "aws_kms_key" "s3_encryption" {
  description             = "KMS key for S3 bucket encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

# === Main website bucket ===
resource "aws_s3_bucket" "root_site" {
  bucket        = "kjellhysjulien.com"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "root_site" {
  bucket = aws_s3_bucket.root_site.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "root_site" {
  bucket        = aws_s3_bucket.root_site.id
  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "root-site/"
}

resource "aws_s3_bucket_public_access_block" "root_site" {
  bucket = aws_s3_bucket.root_site.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "root_site" {
  bucket = aws_s3_bucket.root_site.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_encryption.arn
    }
  }
}

resource "aws_s3_bucket_website_configuration" "root_site" {
  bucket = aws_s3_bucket.root_site.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# === www redirect bucket ===
resource "aws_s3_bucket" "www_redirect" {
  bucket        = "www.kjellhysjulien.com"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "www_redirect" {
  bucket = aws_s3_bucket.www_redirect.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "www_redirect" {
  bucket        = aws_s3_bucket.www_redirect.id
  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "www-redirect/"
}

resource "aws_s3_bucket_public_access_block" "www_redirect" {
  bucket = aws_s3_bucket.www_redirect.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "www_redirect" {
  bucket = aws_s3_bucket.www_redirect.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_encryption.arn
    }
  }
}

resource "aws_s3_bucket_website_configuration" "www_redirect" {
  bucket = aws_s3_bucket.www_redirect.id

  redirect_all_requests_to {
    host_name = "kjellhysjulien.com"
    protocol  = "https"
  }
}

# === Log bucket ===
resource "aws_s3_bucket" "log_bucket" {
  bucket        = "logs.kjellhysjulien.com"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "log_bucket" {
  bucket = aws_s3_bucket.log_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "log_bucket" {
  bucket        = aws_s3_bucket.log_bucket.id
  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "internal-access/"
}

resource "aws_s3_bucket_public_access_block" "log_bucket" {
  bucket = aws_s3_bucket.log_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "log_bucket" {
  bucket = aws_s3_bucket.log_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_encryption.arn
    }
  }
}

# === Policy to allow CloudFront to write logs ===
resource "aws_s3_bucket_policy" "log_bucket_policy" {
  bucket = aws_s3_bucket.log_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "CloudFrontLogsWrite",
        Effect    = "Allow",
        Principal = {
          Service = "cloudfront.amazonaws.com"
        },
        Action    = "s3:PutObject",
        Resource  = "${aws_s3_bucket.log_bucket.arn}/cloudfront/*",
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.website_cdn.arn
          }
        }
      }
    ]
  })
}

# === ACM Certificate (automated validation) ===
resource "aws_acm_certificate" "cert" {
  domain_name               = "kjellhysjulien.com"
  validation_method         = "DNS"
  subject_alternative_names = ["www.kjellhysjulien.com"]
}

resource "aws_route53_zone" "primary" {
  name = "kjellhysjulien.com"
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }

  zone_id = aws_route53_zone.primary.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 300
  records = [each.value.value]
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# === CloudFront CDN ===
resource "aws_cloudfront_distribution" "website_cdn" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  price_class         = "PriceClass_100"
  wait_for_deployment = true
  web_acl_id          = "arn:aws:wafv2:us-east-1:843785657965:global/webacl/CreatedByCloudFront-d140ac24-6856-4d2c-a001-38a2f5e1300a/a832554d-e00a-428e-9f99-213e01f460cb"

  aliases = [
    "kjellhysjulien.com",
    "www.kjellhysjulien.com"
  ]

  origin {
    domain_name = "kjellhysjulien.com.s3-website-us-east-1.amazonaws.com"
    origin_id   = "kjellhysjulien.com.s3-website-us-east-1.amazonaws.com"

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = "http-only"
      origin_ssl_protocols     = ["TLSv1.2"]
      origin_read_timeout      = 30
      origin_keepalive_timeout = 5
    }

    connection_attempts = 3
    connection_timeout  = 10
  }

  default_cache_behavior {
    target_origin_id       = "kjellhysjulien.com.s3-website-us-east-1.amazonaws.com"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    cache_policy_id             = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    response_headers_policy_id = "a0d80d0d-1133-465b-b22c-4149931c0554"

    default_ttl = 0
    min_ttl     = 0
    max_ttl     = 0

    grpc_config {
      enabled = false
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn            = aws_acm_certificate.cert.arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
    cloudfront_default_certificate = false
  }

  logging_config {
    include_cookies = false
    bucket          = "${aws_s3_bucket.log_bucket.bucket}.s3.amazonaws.com"
    prefix          = "cloudfront/"
  }

  tags = {
    Name = "Website"
  }
}

# === Route 53 DNS Records ===
resource "aws_route53_record" "root_a" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "kjellhysjulien.com"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.website_cdn.domain_name
    zone_id                = "Z2FDTNDATAQYW2"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www_a" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "www.kjellhysjulien.com"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.website_cdn.domain_name
    zone_id                = "Z2FDTNDATAQYW2"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "google_verification" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "kjellhysjulien.com"
  type    = "TXT"
  ttl     = 300
  records = ["\"google-site-verification=I8hWClMINMc-m-9zQ08YApAz6CC52DIu0T00hZ-h0Ms\""]
}

resource "aws_route53_record" "ns" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "kjellhysjulien.com"
  type    = "NS"
  ttl     = 172800
  records = [
    "ns-1865.awsdns-41.co.uk.",
    "ns-633.awsdns-15.net.",
    "ns-1497.awsdns-59.org.",
    "ns-288.awsdns-36.com."
  ]
}
