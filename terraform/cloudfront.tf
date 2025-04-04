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

    cache_policy_id            = "658327ea-f89d-4fab-a63d-7e88639e58f6"
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

  # logging_config {
  #   include_cookies = false
  #   bucket          = "${aws_s3_bucket.logs.bucket}.s3.amazonaws.com"
  #   prefix          = "cloudfront/"
  # }

  tags = {
    Name    = "Website"
    Project = "portfolio-website"
    Env     = "prod"
  }
}
