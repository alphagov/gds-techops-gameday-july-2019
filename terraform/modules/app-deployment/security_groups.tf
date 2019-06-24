resource "aws_security_group" "ingress" {
  provider = "aws.${var.provider_role_alias}"

  name        = "ingress"
  description = "ingress"
  vpc_id      = "${aws_vpc.main.id}"
}

resource "aws_security_group" "app" {
  provider = "aws.${var.provider_role_alias}"

  name        = "app"
  description = "app"
  vpc_id      = "${aws_vpc.main.id}"
}

resource "aws_security_group" "db" {
  provider = "aws.${var.provider_role_alias}"

  name        = "db"
  description = "db"
  vpc_id      = "${aws_vpc.main.id}"
}

resource "aws_security_group_rule" "ingress_ingress_from_internet" {
  provider = "aws.${var.provider_role_alias}"

  type = "ingress"

  from_port = 443
  to_port   = 443
  protocol  = "tcp"

  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.ingress.id}"
}

resource "aws_security_group_rule" "ingress_egress_to_app" {
  provider = "aws.${var.provider_role_alias}"

  type = "egress"

  from_port = 0
  to_port   = 65535
  protocol  = "tcp"

  source_security_group_id = "${aws_security_group.app.id}"
  security_group_id        = "${aws_security_group.ingress.id}"
}

resource "aws_security_group_rule" "app_ingress_from_ingress" {
  provider = "aws.${var.provider_role_alias}"

  type = "ingress"

  from_port = 0
  to_port   = 65535
  protocol  = "tcp"

  source_security_group_id = "${aws_security_group.ingress.id}"
  security_group_id        = "${aws_security_group.app.id}"
}

resource "aws_security_group_rule" "app_egress_to_internet" {
  provider = "aws.${var.provider_role_alias}"

  type = "egress"

  from_port = 0
  to_port   = 65535
  protocol  = "tcp"

  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.app.id}"
}

resource "aws_security_group_rule" "db_ingress_from_internet" {
  provider = "aws.${var.provider_role_alias}"

  type = "ingress"

  from_port = 0
  to_port   = 65535
  protocol  = "tcp"

  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.db.id}"
}

resource "aws_security_group_rule" "db_egress_to_internet" {
  provider = "aws.${var.provider_role_alias}"

  type = "egress"

  from_port = 0
  to_port   = 65535
  protocol  = "tcp"

  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.db.id}"
}
