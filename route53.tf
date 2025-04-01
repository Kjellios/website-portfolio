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
  records = ["google-site-verification=I8hWClMINMc-m-9zQ08YApAz6CC52DIu0T00hZ-h0Ms"]
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
