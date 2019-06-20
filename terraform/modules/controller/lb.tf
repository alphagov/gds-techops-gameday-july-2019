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

resource "aws_lb_listener" "ingress_https" {
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

resource "aws_lb_target_group" "concourse" {
  name     = "concourse"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = "${aws_default_vpc.vpc.id}"
}

resource "aws_lb_target_group" "splunk" {
  name     = "splunk"
  port     = 8000
  protocol = "HTTP"
  vpc_id   = "${aws_default_vpc.vpc.id}"
}

resource "aws_lb_target_group" "splunk_hec" {
  name     = "hec"
  port     = 8088
  protocol = "HTTPS"
  vpc_id   = "${aws_default_vpc.vpc.id}"
}

resource "aws_lb_listener_rule" "concourse" {
  listener_arn = "${aws_lb_listener.ingress_https.arn}"
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.concourse.arn}"
  }

  condition {
    field  = "host-header"
    values = ["concourse.*"]
  }
}
