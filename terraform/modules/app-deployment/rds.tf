resource "aws_db_subnet_group" "db" {
  provider = "aws.${var.provider_role_alias}"

  name = "db"

  subnet_ids = [
    "${aws_subnet.z1.id}",
    "${aws_subnet.z2.id}",
  ]
}

resource "aws_db_instance" "db" {
  provider = "aws.${var.provider_role_alias}"

  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "postgres"
  engine_version         = "9.6.11"
  instance_class         = "db.t3.micro"
  identifier             = "app"
  name                   = "app"
  username               = "app"
  password               = "${var.db_password}"
  parameter_group_name   = "default.postgres9.6"
  publicly_accessible    = true
  skip_final_snapshot    = false
  vpc_security_group_ids = ["${aws_security_group.db.id}"]
  db_subnet_group_name   = "${aws_db_subnet_group.db.name}"
}

output "db_host" {
  value = "${aws_db_instance.db.address}"
}
