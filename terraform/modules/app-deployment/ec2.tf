data "aws_ami" "amazon_linux_2" {
  provider = "aws.${var.provider_role_alias}"

  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }

  owners = ["amazon"]
}

resource "aws_iam_role" "app" {
  provider = "aws.${var.provider_role_alias}"

  name = "app"

  assume_role_policy = <<-ROLE
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
  ROLE
}

resource "aws_iam_instance_profile" "app" {
  provider = "aws.${var.provider_role_alias}"

  name = "${aws_iam_role.app.name}"
  role = "${aws_iam_role.app.name}"
}

resource "aws_iam_role_policy_attachment" "app_ssm" {
  provider = "aws.${var.provider_role_alias}"

  role       = "${aws_iam_role.app.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

data "template_file" "app_init" {
  template = "${file("${path.module}/files/init.sh")}"

  vars {
    db_host     = "${aws_db_instance.db.address}"
    db_password = "${var.db_password}"
  }
}

resource "aws_instance" "app" {
  provider = "aws.${var.provider_role_alias}"

  ami                         = "${data.aws_ami.amazon_linux_2.id}"
  instance_type               = "t2.medium"
  subnet_id                   = "${aws_subnet.z1.id}"
  iam_instance_profile        = "${aws_iam_instance_profile.app.name}"
  user_data                   = "${data.template_file.app_init.rendered}"
  associate_public_ip_address = true

  vpc_security_group_ids = ["${aws_security_group.app.id}"]

  tags = {
    Name = "app"
  }
}

resource "aws_lb_target_group_attachment" "app_app" {
  provider = "aws.${var.provider_role_alias}"

  target_group_arn = "${aws_lb_target_group.app.arn}"
  target_id        = "${aws_instance.app.id}"
  port             = 8080
}
