variable "provider_role_arn" {}
variable "provider_role_alias" {}
variable "simulate_az_failure" {}
variable "root_domain" {}
variable "subdomain" {}
variable "db_password" {}

variable "participants" {
  type = "list"
}

provider "aws" {
  alias = "${var.provider_role_alias}"

  assume_role {
    role_arn = "${var.provider_role_arn}"
  }
}
