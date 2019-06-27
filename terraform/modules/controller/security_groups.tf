# LB

resource "aws_security_group" "ingress" {
  name        = "ingress"
  description = "ingress"
  vpc_id      = "${aws_default_vpc.vpc.id}"
}

resource "aws_security_group_rule" "ingress_ingress_from_internet" {
  type = "ingress"

  from_port = 443
  to_port   = 443
  protocol  = "tcp"

  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.ingress.id}"
}

resource "aws_security_group_rule" "ingress_ingress_80_from_internet" {
  type = "ingress"

  from_port = 80
  to_port   = 80
  protocol  = "tcp"

  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.ingress.id}"
}

resource "aws_security_group_rule" "ingress_egress_to_concourse" {
  type = "egress"

  from_port = 0
  to_port   = 65535
  protocol  = "tcp"

  source_security_group_id = "${aws_security_group.concourse.id}"
  security_group_id        = "${aws_security_group.ingress.id}"
}

resource "aws_security_group_rule" "ingress_egress_to_oidc" {
  type = "egress"

  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.ingress.id}"
}

resource "aws_security_group_rule" "ingress_egress_to_splunk" {
  type = "egress"

  from_port = 0
  to_port   = 65535
  protocol  = "tcp"

  source_security_group_id = "${aws_security_group.splunk.id}"
  security_group_id        = "${aws_security_group.ingress.id}"
}

# Concourse

resource "aws_security_group" "concourse" {
  name        = "concourse"
  description = "concourse"
  vpc_id      = "${aws_default_vpc.vpc.id}"
}

resource "aws_security_group_rule" "concourse_ingress_from_ingress" {
  type = "ingress"

  from_port = 0
  to_port   = 65535
  protocol  = "tcp"

  source_security_group_id = "${aws_security_group.ingress.id}"
  security_group_id        = "${aws_security_group.concourse.id}"
}

resource "aws_security_group_rule" "concourse_egress_to_internet" {
  type = "egress"

  from_port = 0
  to_port   = 65535
  protocol  = "tcp"

  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.concourse.id}"
}

# Splunk

resource "aws_security_group" "splunk" {
  name        = "splunk"
  description = "splunk"
  vpc_id      = "${aws_default_vpc.vpc.id}"
}

resource "aws_security_group_rule" "splunk_ingress_from_ingress" {
  type = "ingress"

  from_port = 0
  to_port   = 65535
  protocol  = "tcp"

  source_security_group_id = "${aws_security_group.ingress.id}"
  security_group_id        = "${aws_security_group.splunk.id}"
}

resource "aws_security_group_rule" "splunk_egress_to_internet" {
  type = "egress"

  from_port = 0
  to_port   = 65535
  protocol  = "tcp"

  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.splunk.id}"
}
