resource "aws_lb" "ingress" {
  provider = "aws.${var.provider_role_alias}"

  name               = "ingress"
  internal           = false
  load_balancer_type = "application"

  subnets = [
    "${aws_subnet.z1.id}",
    "${aws_subnet.z2.id}",
  ]

  security_groups = [
    "${aws_security_group.ingress.id}",
  ]
}

resource "aws_lb_target_group" "app" {
  provider = "aws.${var.provider_role_alias}"

  name     = "app"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.main.id}"
}

resource "aws_lb_listener" "ingress_https" {
  provider = "aws.${var.provider_role_alias}"

  load_balancer_arn = "${aws_lb.ingress.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = "${aws_acm_certificate.subdomain_wildcard.arn}"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.app.arn}"
  }
}
