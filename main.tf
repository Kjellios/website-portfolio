provider "aws" {
  region = "us-east-1"
}

# === S3 Buckets ===

# Main website bucket
resource "aws_s3_bucket" "root_site" {
  bucket         = "kjellhysjulien.com"
  force_destroy  = true
}

# Public access block for root site bucket (allows public reads)
resource "aws_s3_bucket_public_access_block" "root_site" {
  bucket                  = aws_s3_bucket.root_site.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Bucket policy to allow public read access for website files
resource "aws_s3_bucket_policy" "root_site_policy" {
  bucket = aws_s3_bucket.root_site.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.root_site.arn}/*"
      }
    ]
  })
}

# Website config for root site
resource "aws_s3_bucket_website_configuration" "root_site" {
  bucket = aws_s3_bucket.root_site.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# www bucket (redirects to root)
resource "aws_s3_bucket" "www_redirect" {
  bucket        = "www.kjellhysjulien.com"
  force_destroy = true
}

resource "aws_s3_bucket_website_configuration" "www_redirect" {
  bucket = aws_s3_bucket.www_redirect.id

  redirect_all_requests_to {
    host_name = "kjellhysjulien.com"
    protocol  = "https"
  }
}

# Log bucket
resource "aws_s3_bucket" "log_bucket" {
  bucket        = "logs.kjellhysjulien.com"
  force_destroy = true
}

# === CloudFront Distribution ===

resource "aws_cloudfront_distribution" "website_cdn" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  price_class         = "PriceClass_100"
  wait_for_deployment = true
  web_acl_id          = "arn:aws:wafv2:us-east-1:843785657965:global/webacl/CreatedByCloudFront-d140ac24-6856-4d2c-a001-38a2f5e1300a/a832554d-e00a-428e-9f99-213e01f460cb"

  aliases = [
    "kjellhysjulien.com",
    "www.kjellhysjulien.com",
  ]

  origin {
    domain_name = "kjellhysjulien.com.s3-website-us-east-1.amazonaws.com"
    origin_id   = "kjellhysjulien.com.s3-website-us-east-1.amazonaws.com"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
      origin_read_timeout    = 30
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
    acm_certificate_arn            = "arn:aws:acm:us-east-1:843785657965:certificate/00c8e041-bf4b-408c-b30a-12149e298e22"
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
    cloudfront_default_certificate = false
  }

  logging_config {
    include_cookies = false
    bucket          = "logs.kjellhysjulien.com.s3.amazonaws.com"
    prefix          = "cloudfront/"
  }

  tags = {
    Name = "Website"
  }
}

# === Route 53 DNS ===

# Hosted zone
resource "aws_route53_zone" "primary" {
  name = "kjellhysjulien.com"
}

# A record (root domain -> CloudFront)
resource "aws_route53_record" "root_a" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "kjellhysjulien.com"
  type    = "A"

  alias {
    name                   = "dka09xss205q1.cloudfront.net"
    zone_id                = "Z2FDTNDATAQYW2"
    evaluate_target_health = false
  }
}

# A record (www -> CloudFront)
resource "aws_route53_record" "www_a" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "www.kjellhysjulien.com"
  type    = "A"

  alias {
    name                   = "dka09xss205q1.cloudfront.net"
    zone_id                = "Z2FDTNDATAQYW2"
    evaluate_target_health = false
  }
}

# TXT record for Google Site Verification
resource "aws_route53_record" "google_verification" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "kjellhysjulien.com"
  type    = "TXT"
  ttl     = 300
  records = ["\"google-site-verification=I8hWClMINMc-m-9zQ08YApAz6CC52DIu0T00hZ-h0Ms\""]
}

# ACM validation for root domain
resource "aws_route53_record" "acm_validation_root" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "_937f42ec8885746b4f6b190025185e1f.kjellhysjulien.com"
  type    = "CNAME"
  ttl     = 300
  records = ["_69156284e4bedb7e897130575c24a390.mhbtsbpdnt.acm-validations.aws."]
}

# ACM validation for www subdomain
resource "aws_route53_record" "acm_validation_www" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "_5037de2fa190580de504e2b1256d1a7e.www.kjellhysjulien.com"
  type    = "CNAME"
  ttl     = 300
  records = ["_2a16d490270f0ca013127b9a8077abcc.mhbtsbpdnt.acm-validations.aws."]
}

# NS record for root domain (if needed manually)
resource "aws_route53_record" "ns" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "kjellhysjulien.com"
  type    = "NS"
  ttl     = 172800
  records = [
    "ns-1865.awsdns-41.co.uk.",
    "ns-633.awsdns-15.net.",
    "ns-1497.awsdns-59.org.",
    "ns-288.awsdns-36.com.",
  ]
}
