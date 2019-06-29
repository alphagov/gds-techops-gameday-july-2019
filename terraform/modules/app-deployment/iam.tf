locals {
  aws_account_id = "redacted"
  aws_iam_role_suffix = "redacted"
}

resource "aws_iam_role" "gameday" {
  provider = "aws.${var.provider_role_alias}"

  name = "gameday"

  assume_role_policy = <<-POLICY
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": ${jsonencode(formatlist(
            "arn:aws:iam::${local.aws_account_id}:user/%s@${local.aws_iam_role_suffix}",
            var.participants
          ))}
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
  POLICY
}

resource "aws_iam_role_policy_attachment" "gameday_admin" {
  provider = "aws.${var.provider_role_alias}"

  role       = "${aws_iam_role.gameday.name}"
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

data "template_file" "policy" {
  template = "${file("${path.module}/files/gameday_admin_limits_policy.json")}"

  vars {
    account_id = "${data.aws_caller_identity.current.account_id}"
  }
}

resource "aws_iam_policy" "gameday_admin_limits" {
  provider = "aws.${var.provider_role_alias}"

  name = "gameday_limits"

  policy = "${data.template_file.policy.rendered}"
}

resource "aws_iam_role_policy_attachment" "gameday_admin_limits" {
  provider = "aws.${var.provider_role_alias}"

  role       = "${aws_iam_role.gameday.name}"
  policy_arn = "${aws_iam_policy.gameday_admin_limits.arn}"
}

resource "aws_iam_role" "gameday_vo" {
  provider = "aws.${var.provider_role_alias}"

  name = "gameday_vo"

  assume_role_policy = <<-POLICY
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": ${jsonencode(formatlist(
            "arn:aws:iam::${local.aws_account_id}:user/%s@${local.aws_iam_role_suffix}",
            var.participants_vo
          ))}
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
  POLICY
}

resource "aws_iam_role_policy_attachment" "gameday_vo" {
  provider = "aws.${var.provider_role_alias}"

  role       = "${aws_iam_role.gameday_vo.name}"
  policy_arn = "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"
}



resource "aws_iam_role" "lambda" {
  provider = "aws.${var.provider_role_alias}"
  name = "lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda-policy" {
  provider = "aws.${var.provider_role_alias}"
  role       = "${aws_iam_role.lambda.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
