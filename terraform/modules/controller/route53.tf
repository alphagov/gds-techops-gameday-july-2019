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
