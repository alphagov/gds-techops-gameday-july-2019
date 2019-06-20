locals {
  fqdn = "${var.subdomain}.${var.root_domain}"
}

data "aws_route53_zone" "root" {
  name = "${var.root_domain}."
}

resource "aws_route53_zone" "subdomain" {
  name = "${local.fqdn}"
}

resource "aws_route53_record" "root_to_subdomain_delegation" {
  zone_id = "${data.aws_route53_zone.root.zone_id}"
  name    = "${local.fqdn}"
  type    = "NS"
  ttl     = "300"
  records = ["${aws_route53_zone.subdomain.name_servers}"]
}

resource "aws_route53_record" "ingress" {
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
  zone_id = "${aws_route53_zone.subdomain.zone_id}"
  name    = "*.${local.fqdn}"
  type    = "A"

  alias {
    name                   = "${aws_lb.ingress.dns_name}"
    zone_id                = "${aws_lb.ingress.zone_id}"
    evaluate_target_health = false
  }
}
