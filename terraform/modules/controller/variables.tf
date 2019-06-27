variable "root_domain" {
  description = "The domain under which we will create our zone"
  type        = "string"
}

variable "subdomain" {
  description = "The subdomain for our zone"
  type        = "string"
}

module "gds_ips" {
  source = "../gds-ips"
}

data "aws_caller_identity" "current" {}

variable "oidc_client_id" {
  description = "OIDC client ID"
  type        = "string"
}

variable "oidc_client_secret" {
  description = "OIDC client secret"
  type        = "string"
}
