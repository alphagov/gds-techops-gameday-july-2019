resource "aws_iam_role" "splunk" {
  name = "splunk"

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

resource "aws_iam_instance_profile" "splunk" {
  name = "${aws_iam_role.splunk.name}"
  role = "${aws_iam_role.splunk.name}"
}

resource "aws_iam_role_policy_attachment" "splunk_ssm" {
  role       = "${aws_iam_role.splunk.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "random_string" "splunk_admin_password" {
  length  = 64
  special = false
}

data "template_file" "splunk_init" {
  template = "${file("${path.module}/files/splunk-init.sh")}"

  vars {
    admin_password = "${random_string.splunk_admin_password.result}"
    external_host  = "splunk.${local.fqdn}"
  }
}

resource "aws_instance" "splunk" {
  ami                  = "${data.aws_ami.amazon_linux_2.id}"
  instance_type        = "t2.medium"
  subnet_id            = "${aws_default_subnet.z1.id}"
  iam_instance_profile = "${aws_iam_instance_profile.splunk.name}"
  user_data            = "${data.template_file.splunk_init.rendered}"

  vpc_security_group_ids = [
    "${aws_security_group.splunk.id}",
    "${aws_default_security_group.default.id}",
  ]

  root_block_device {
    volume_size = 50
  }

  tags = {
    Name = "splunk"
  }
}

resource "aws_eip_association" "splunk" {
  instance_id   = "${aws_instance.splunk.id}"
  allocation_id = "${aws_eip.splunk.id}"
}

resource "aws_lb_target_group_attachment" "splunk_splunk" {
  target_group_arn = "${aws_lb_target_group.splunk.arn}"
  target_id        = "${aws_instance.splunk.id}"
  port             = 8080
}

resource "aws_lb_target_group_attachment" "splunk_admin" {
  target_group_arn = "${aws_lb_target_group.splunk_admin.arn}"
  target_id        = "${aws_instance.splunk.id}"
  port             = 8089
}

resource "aws_lb_target_group_attachment" "hec" {
  target_group_arn = "${aws_lb_target_group.hec.arn}"
  target_id        = "${aws_instance.splunk.id}"
  port             = 8088
}

output "splunk_admin_password" {
  value = "${random_string.splunk_admin_password.result}"
}

output "splunk_url" {
  value = "https://splunk.${local.fqdn}"
}

output "hec_url" {
  value = "https://hec.${local.fqdn}"
}
