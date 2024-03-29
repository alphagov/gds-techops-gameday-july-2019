variable "provider_role_arn" {}
variable "provider_role_alias" {}

provider "aws" {
  alias  = "${var.provider_role_alias}"
  region = "eu-west-2"

  assume_role {
    role_arn = "${var.provider_role_arn}"
  }
}
