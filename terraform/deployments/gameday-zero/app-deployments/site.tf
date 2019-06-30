terraform {
  backend "s3" {
    bucket = "gds-tech-ops-gameday-zero-tfstate"
    key    = "app-deployments.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  region = "eu-west-2"
}

locals {
  db_password = "when-you-invent-the-ship-you-invent-the-shipwreck-2019"
}

module "app_deployment_one" {
  source = "../../../modules/app-deployment"

  provider_role_arn   = "arn:aws:iam::redacted:role/bootstrap"
  provider_role_alias = "one"

  root_domain = "game.gds-reliability.engineering"
  subdomain   = "one"
  db_password = "${local.db_password}"

  participants    = []
  participants_vo = []
}


module "app_deployment_two" {
  source = "../../../modules/app-deployment"

  provider_role_arn   = "arn:aws:iam::redacted:role/bootstrap"
  provider_role_alias = "two"

  root_domain = "game.gds-reliability.engineering"
  subdomain   = "two"
  db_password = "${local.db_password}"

  participants    = []
  participants_vo = []
}

module "app_deployment_three" {
  source = "../../../modules/app-deployment"

  provider_role_arn   = "arn:aws:iam::redacted:role/bootstrap"
  provider_role_alias = "three"

  root_domain = "game.gds-reliability.engineering"
  subdomain   = "three"
  db_password = "${local.db_password}"

  participants    = []
  participants_vo = []
}

module "app_deployment_four" {
  source = "../../../modules/app-deployment"

  provider_role_arn   = "arn:aws:iam::redacted:role/bootstrap"
  provider_role_alias = "four"

  root_domain = "game.gds-reliability.engineering"
  subdomain   = "four"
  db_password = "${local.db_password}"

  participants    = []
  participants_vo = []
}

module "app_deployment_five" {
  source = "../../../modules/app-deployment"

  provider_role_arn   = "arn:aws:iam::redacted:role/bootstrap"
  provider_role_alias = "five"

  root_domain = "game.gds-reliability.engineering"
  subdomain   = "five"
  db_password = "${local.db_password}"

  participants    = []
  participants_vo = []
}

module "app_deployment_six" {
  source = "../../../modules/app-deployment"

  provider_role_arn   = "arn:aws:iam::redacted:role/bootstrap"
  provider_role_alias = "six"

  root_domain = "game.gds-reliability.engineering"
  subdomain   = "six"
  db_password = "${local.db_password}"

  participants    = []
  participants_vo = []
}

module "app_deployment_seven" {
  source = "../../../modules/app-deployment"

  provider_role_arn   = "arn:aws:iam::redacted:role/bootstrap"
  provider_role_alias = "seven"

  root_domain = "game.gds-reliability.engineering"
  subdomain   = "seven"
  db_password = "${local.db_password}"

  participants    = []
  participants_vo = []
}

output "database_password" {
  value = "${local.db_password}"
}

output "deployment_one_db_host" {
  value = "${module.app_deployment_one.db_host}"
}

output "deployment_two_db_host" {
  value = "${module.app_deployment_two.db_host}"
}

output "deployment_three_db_host" {
  value = "${module.app_deployment_three.db_host}"
}

output "deployment_four_db_host" {
  value = "${module.app_deployment_four.db_host}"
}

output "deployment_five_db_host" {
  value = "${module.app_deployment_five.db_host}"
}

output "deployment_six_db_host" {
  value = "${module.app_deployment_six.db_host}"
}

output "deployment_seven_db_host" {
  value = "${module.app_deployment_seven.db_host}"
}
