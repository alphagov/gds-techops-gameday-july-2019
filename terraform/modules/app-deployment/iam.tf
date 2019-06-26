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
            "arn:aws:iam::622626885786:user/%s@digital.cabinet-office.gov.uk",
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
            "arn:aws:iam::622626885786:user/%s@digital.cabinet-office.gov.uk",
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
