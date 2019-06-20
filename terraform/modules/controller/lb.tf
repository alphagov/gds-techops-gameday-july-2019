resource "aws_lb" "ingress" {
  name               = "ingress"
  internal           = false
  load_balancer_type = "application"

  subnets = [
    "${aws_default_subnet.z1.id}",
    "${aws_default_subnet.z2.id}",
    "${aws_default_subnet.z3.id}",
  ]

  security_groups = [
    "${aws_security_group.ingress.id}",
  ]
}

resource "aws_lb_listener" "ingress_default" {
  load_balancer_arn = "${aws_lb.ingress.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = "${aws_acm_certificate.subdomain_wildcard.arn}"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "🐕"
      status_code  = "200"
    }
  }
}

