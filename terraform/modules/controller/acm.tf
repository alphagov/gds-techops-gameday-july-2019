resource "aws_acm_certificate" "subdomain_wildcard" {
  validation_method         = "DNS"
  domain_name               = "${local.fqdn}"
  subject_alternative_names = ["*.${local.fqdn}"]
}

resource "aws_route53_record" "subdomain_wildcard_validation" {
  name = "${
    aws_acm_certificate.subdomain_wildcard.domain_validation_options.0.resource_record_name
  }"

  type = "${
    aws_acm_certificate.subdomain_wildcard.domain_validation_options.0.resource_record_type
  }"

  records = ["${
    aws_acm_certificate.subdomain_wildcard.domain_validation_options.0.resource_record_value
  }"]

  zone_id = "${aws_route53_zone.subdomain.id}"
  ttl     = 60
}

resource "aws_acm_certificate_validation" "subdomain_wildcard" {
  certificate_arn = "${
    aws_acm_certificate.subdomain_wildcard.arn
  }"

  validation_record_fqdns = ["${
    aws_route53_record.subdomain_wildcard_validation.fqdn
  }"]
}
