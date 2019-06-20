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
