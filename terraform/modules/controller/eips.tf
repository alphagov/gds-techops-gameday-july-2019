resource "aws_eip" "concourse" {
  vpc      = true
}

resource "aws_eip" "splunk" {
  vpc      = true
}
