# Lambda

resource "aws_lambda_function" "gde-docs-lambda" {
  filename         = "../../../../backing-services/gde-docs.zip"
  source_code_hash = "${filebase64sha256("../../../../backing-services/gde-docs.zip")}"
  function_name    = "gde-docs-lambda"
  role             = "${aws_iam_role.gde-docs-iam.arn}"
  handler          = "game_play_lambda.lambda_handler"
  runtime          = "python3.7"
}

resource "aws_iam_role" "gde-docs-iam" {
  name = "iam_for_lambda"

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

resource "aws_iam_role_policy_attachment" "lambda-policy-attach" {
  role       = "${aws_iam_role.gde-docs-iam.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy" "gde-docs-iam_policy" {
  name = "test_policy"
  role = "${aws_iam_role.gde-docs-iam.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "arn:aws:logs:eu-west-2:${data.aws_caller_identity.current.account_id}:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:eu-west-2:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/gde-docs-lambda:*"
            ]
        }
    ]
}
EOF
}

resource "aws_lambda_permission" "with_lb" {
  statement_id  = "AllowExecutionFromlb"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.gde-docs-lambda.arn}"
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = "${aws_lb_target_group.documentation.arn}"
}

resource "aws_lb_target_group_attachment" "gde-docs" {
  target_group_arn = "${aws_lb_target_group.documentation.arn}"
  target_id        = "${aws_lambda_function.gde-docs-lambda.arn}"
  depends_on       = ["aws_lambda_permission.with_lb"]
}
