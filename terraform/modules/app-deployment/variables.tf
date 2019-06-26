variable "provider_role_arn" {}
variable "provider_role_alias" {}
variable "root_domain" {}
variable "subdomain" {}
variable "db_password" {}

variable "participants" {
  type = "list"
}

variable "participants_vo" {
  type = "list"
}

provider "aws" {
  alias  = "${var.provider_role_alias}"
  region = "eu-west-2"

  assume_role {
    role_arn = "${var.provider_role_arn}"
  }
}
