locals {
  fqdn = "${var.subdomain}.${var.root_domain}"
}

data "aws_route53_zone" "root" {
  # Provider omitted because on parent

  name = "${var.root_domain}."
}

resource "aws_route53_zone" "subdomain" {
  provider = "aws.${var.provider_role_alias}"

  name = "${local.fqdn}"
}

resource "aws_route53_record" "root_to_subdomain_delegation" {
  # Provider omitted because on parent

  zone_id = "${data.aws_route53_zone.root.zone_id}"
  name    = "${local.fqdn}"
  type    = "NS"
  ttl     = "300"
  records = ["${aws_route53_zone.subdomain.name_servers}"]
}

resource "aws_route53_record" "ingress" {
  provider = "aws.${var.provider_role_alias}"

  zone_id = "${aws_route53_zone.subdomain.zone_id}"
  name    = "${local.fqdn}"
  type    = "A"

  alias {
    name                   = "${aws_lb.ingress.dns_name}"
    zone_id                = "${aws_lb.ingress.zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "ingress_wildcard" {
  provider = "aws.${var.provider_role_alias}"

  zone_id = "${aws_route53_zone.subdomain.zone_id}"
  name    = "*.${local.fqdn}"
  type    = "A"

  alias {
    name                   = "${aws_lb.ingress.dns_name}"
    zone_id                = "${aws_lb.ingress.zone_id}"
    evaluate_target_health = false
  }
}
