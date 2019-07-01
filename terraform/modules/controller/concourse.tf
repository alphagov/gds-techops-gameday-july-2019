resource "aws_iam_role" "concourse" {
  name = "concourse"

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

resource "aws_iam_instance_profile" "concourse" {
  name = "${aws_iam_role.concourse.name}"
  role = "${aws_iam_role.concourse.name}"
}

resource "aws_iam_role_policy_attachment" "concourse_admin" {
  role       = "${aws_iam_role.concourse.name}"
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "random_string" "concourse_local_user_password" {
  length  = 100
  special = false
}

resource "random_string" "concourse_postgres_password" {
  length  = 100
  special = false
}

resource "aws_db_instance" "concourse" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "9.6.11"
  instance_class       = "db.t3.micro"
  identifier           = "concourse"
  name                 = "concourse"
  username             = "concourse"
  password             = "${random_string.concourse_postgres_password.result}"
  parameter_group_name = "default.postgres9.6"
  publicly_accessible  = true
  skip_final_snapshot  = false
}

data "template_file" "concourse_init" {
  template = "${file("${path.module}/files/concourse-init.sh")}"

  vars {
    postgres_host       = "${aws_db_instance.concourse.address}"
    postgres_password   = "${random_string.concourse_postgres_password.result}"
    local_user_password = "${random_string.concourse_local_user_password.result}"
    external_url        = "https://concourse.${local.fqdn}"
  }
}

resource "aws_instance" "concourse" {
  ami                  = "${data.aws_ami.amazon_linux_2.id}"
  instance_type        = "m5.8xlarge"
  subnet_id            = "${aws_default_subnet.z1.id}"
  iam_instance_profile = "${aws_iam_instance_profile.concourse.name}"
  user_data            = "${data.template_file.concourse_init.rendered}"
  ebs_optimized        = "true"

  vpc_security_group_ids = [
    "${aws_security_group.concourse.id}",
    "${aws_default_security_group.default.id}",
  ]

  root_block_device {
    volume_size = 50
  }

  tags = {
    Name = "concourse"
  }
}

resource "aws_eip_association" "concourse" {
  instance_id   = "${aws_instance.concourse.id}"
  allocation_id = "${aws_eip.concourse.id}"
}

resource "aws_lb_target_group_attachment" "concourse_concourse" {
  target_group_arn = "${aws_lb_target_group.concourse.arn}"
  target_id        = "${aws_instance.concourse.id}"
  port             = 8080
}

output "concourse_username" {
  value = "doge"
}

output "concourse_password" {
  value = "${random_string.concourse_local_user_password.result}"
}

output "concourse_url" {
  value = "https://concourse.${local.fqdn}"
}

output "concourse_db_password" {
  value = "${random_string.concourse_postgres_password.result}"
}

output "concourse_db_host" {
  value = "${aws_db_instance.concourse.address}"
}
