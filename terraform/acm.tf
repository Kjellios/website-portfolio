resource "aws_acm_certificate" "cert" {
  domain_name               = "kjellhysjulien.com"
  validation_method         = "DNS"
  subject_alternative_names = ["www.kjellhysjulien.com"]

  tags = {
    Name    = "Portfolio Site Certificate"
    Project = "portfolio-website"
    Env     = "prod"
  }
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}
