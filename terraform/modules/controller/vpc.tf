resource "aws_default_vpc" "vpc" {}

resource "aws_default_subnet" "z1" {
  availability_zone = "eu-west-2a"
}

resource "aws_default_subnet" "z2" {
  availability_zone = "eu-west-2b"
}

resource "aws_default_subnet" "z3" {
  availability_zone = "eu-west-2c"
}

resource "aws_default_security_group" "default" {
  vpc_id = "${aws_default_vpc.vpc.id}"

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
