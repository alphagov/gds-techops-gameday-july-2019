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
