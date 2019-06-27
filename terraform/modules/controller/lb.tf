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

resource "aws_lb_listener" "ingress_http" {
  load_balancer_arn = "${aws_lb.ingress.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
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
  port     = 8080
  protocol = "HTTP"
  vpc_id   = "${aws_default_vpc.vpc.id}"
}

resource "aws_lb_target_group" "splunk_admin" {
  name     = "splunk-admin"
  port     = 8089
  protocol = "HTTPS"
  vpc_id   = "${aws_default_vpc.vpc.id}"
}

resource "aws_lb_target_group" "hec" {
  name     = "hec"
  port     = 8088
  protocol = "HTTPS"
  vpc_id   = "${aws_default_vpc.vpc.id}"
}

resource "aws_lb_target_group" "documentation" {
  name        = "documentation"
  target_type = "lambda"

  health_check {
    path     = "/"
    matcher  = "200"
    interval = "60"
  }
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

resource "aws_lb_listener_rule" "splunk" {
  listener_arn = "${aws_lb_listener.ingress_https.arn}"
  priority     = 101

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.splunk.arn}"
  }

  condition {
    field  = "host-header"
    values = ["splunk.*"]
  }
}

resource "aws_lb_listener_rule" "splunk_admin" {
  listener_arn = "${aws_lb_listener.ingress_https.arn}"
  priority     = 102

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.splunk_admin.arn}"
  }

  condition {
    field  = "host-header"
    values = ["splunk-admin.*"]
  }
}

resource "aws_lb_listener_rule" "hec" {
  listener_arn = "${aws_lb_listener.ingress_https.arn}"
  priority     = 103

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.hec.arn}"
  }

  condition {
    field  = "host-header"
    values = ["hec.*"]
  }
}

resource "aws_lb_listener_rule" "documentation_auth" {
  listener_arn = "${aws_lb_listener.ingress_https.arn}"
  priority     = 104

  action {
    type = "authenticate-oidc"

    authenticate_oidc {
      authorization_endpoint     = "https://accounts.google.com/o/oauth2/auth"
      client_id                  = "${var.oidc_client_id}"
      client_secret              = "${var.oidc_client_secret}"
      issuer                     = "https://accounts.google.com"
      token_endpoint             = "https://oauth2.googleapis.com/token"
      user_info_endpoint         = "https://openidconnect.googleapis.com/v1/userinfo"
      on_unauthenticated_request = "authenticate"
    }
  }

  action {
    target_group_arn = "${aws_lb_target_group.documentation.arn}"
    type             = "forward"
  }

  condition {
    field  = "path-pattern"
    values = ["/auth"]
  }

  condition {
    field  = "host-header"
    values = ["docs.*"]
  }
}

resource "aws_lb_listener_rule" "documentation" {
  listener_arn = "${aws_lb_listener.ingress_https.arn}"
  priority     = 105

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.documentation.arn}"
  }

  condition {
    field  = "host-header"
    values = ["docs.*"]
  }
}
