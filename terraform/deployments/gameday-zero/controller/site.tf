terraform {
  backend "s3" {
    bucket = "gds-tech-ops-gameday-zero-tfstate"
    key    = "controller.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  region = "eu-west-2"
}

module "controller" {
  source = "../../../modules/controller"

  root_domain = "game.gds-reliability.engineering"
  subdomain   = "zero"
}

output "concourse_username" {
  value = "${module.controller.concourse_username}"
}

output "concourse_password" {
  value = "${module.controller.concourse_password}"
}

output "concourse_url" {
  value = "${module.controller.concourse_url}"
}

output "splunk_url" {
  value = "${module.controller.splunk_url}"
}

output "hec_url" {
  value = "${module.controller.hec_url}"
}

output "splunk_admin_password" {
  value = "${module.controller.splunk_admin_password}"
}
