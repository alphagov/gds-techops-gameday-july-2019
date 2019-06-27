# Lambda

resource "aws_lambda_layer_version" "scoreboard_layer1" {
  filename         = "../../../../scoreboard/scoreboard_layer1.zip"
  source_code_hash = "${filebase64sha256("../../../../scoreboard/scoreboard_layer1.zip")}"
  layer_name = "scoreboard_dash1"

  compatible_runtimes = ["python3.6"]
}

resource "aws_lambda_layer_version" "scoreboard_layer2" {
  filename         = "../../../../scoreboard/scoreboard_layer2.zip"
  source_code_hash = "${filebase64sha256("../../../../scoreboard/scoreboard_layer2.zip")}"
  layer_name = "scoreboard_dash2"

  compatible_runtimes = ["python3.6"]
}

resource "aws_lambda_function" "scoreboard-lambda" {
  filename         = "../../../../scoreboard/scoreboard.zip"
  source_code_hash = "${filebase64sha256("../../../../scoreboard/scoreboard.zip")}"
  function_name    = "scoreboard"
  role             = "${aws_iam_role.scoreboard-iam.arn}"
  handler          = "scoreboard.lambda_handler"
  runtime          = "python3.6"
  timeout          = "30"
  layers           = ["${aws_lambda_layer_version.scoreboard_layer1.arn}", "${aws_lambda_layer_version.scoreboard_layer2.arn}"]
}

resource "aws_iam_role" "scoreboard-iam" {
  name = "iam_for_lambda_scoreboard"

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

resource "aws_iam_role_policy_attachment" "lambda-policy-attach-scoreboard" {
  role       = "${aws_iam_role.scoreboard-iam.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy" "scoreboard-iam_policy" {
  name = "test_policy"
  role = "${aws_iam_role.scoreboard-iam.id}"

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
                "arn:aws:logs:eu-west-2:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/scoreboardc-lambda:*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:D*",
                "dynamodb:G*",
                "dynamodb:S*",
                "dynamodb:Q*",
                "dynamodb:L*"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF
}

resource "aws_lambda_permission" "with_lb_scoreboard" {
  statement_id  = "AllowExecutionFromlb"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.scoreboard-lambda.arn}"
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = "${aws_lb_target_group.scoreboard.arn}"
}

resource "aws_lb_target_group_attachment" "scoreboard" {
  target_group_arn = "${aws_lb_target_group.scoreboard.arn}"
  target_id        = "${aws_lambda_function.scoreboard-lambda.arn}"
  depends_on       = ["aws_lambda_permission.with_lb"]
}
