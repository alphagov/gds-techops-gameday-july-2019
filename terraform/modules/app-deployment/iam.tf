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

  role = "${aws_iam_role.gameday.name}"
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
