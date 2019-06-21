resource "aws_vpc" "main" {
  provider = "aws.${var.provider_role_alias}"

  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "gw" {
  provider = "aws.${var.provider_role_alias}"

  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_route_table" "main" {
  provider = "aws.${var.provider_role_alias}"

  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = "${aws_internet_gateway.gw.id}"
  }
}

resource "aws_subnet" "z1" {
  provider = "aws.${var.provider_role_alias}"

  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-2a"
}

resource "aws_route_table_association" "z1" {
  provider = "aws.${var.provider_role_alias}"

  subnet_id      = "${aws_subnet.z1.id}"
  route_table_id = "${aws_route_table.main.id}"
}

resource "aws_subnet" "z2" {
  provider = "aws.${var.provider_role_alias}"

  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-west-2b"
}

resource "aws_route_table_association" "z2" {
  provider = "aws.${var.provider_role_alias}"

  subnet_id      = "${aws_subnet.z2.id}"
  route_table_id = "${aws_route_table.main.id}"
}

resource "aws_network_acl" "main" {
  provider = "aws.${var.provider_role_alias}"

  vpc_id = "${aws_vpc.main.id}"

  subnet_ids = [
    "${aws_subnet.z1.id}",
    "${aws_subnet.z2.id}",
  ]

  ingress {
    # Z1
    action     = "allow"
    protocol   = -1
    rule_no    = 100
    cidr_block = "10.0.1.0/24"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    # Z2
    action     = "allow"
    protocol   = -1
    rule_no    = 101
    cidr_block = "10.0.2.0/24"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    # Any
    action     = "allow"
    protocol   = -1
    rule_no    = 102
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
}
