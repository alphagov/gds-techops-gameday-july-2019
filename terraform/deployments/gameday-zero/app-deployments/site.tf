terraform {
  backend "s3" {
    bucket = "gds-tech-ops-gameday-zero-tfstate"
    key    = "app-deployments.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {}

locals {
	db_password = "when-you-invent-the-ship-you-invent-the-shipwreck-2019"
}

module "app_deployment_one" {
  source = "../../../modules/app-deployment"

  provider_role_arn   = "arn:aws:iam::532889539897:role/bootstrap"
  provider_role_alias = "one"

  root_domain = "game.gds-reliability.engineering"
  subdomain   = "one"
	db_password = "${local.db_password}"

	participants = [
		"rafal.proszowski",
		"richard.towers",
	]
}

output "database_password" {
  value = "${local.db_password}"
}

output "deployment_one_db_host" {
  value = "${module.app_deployment_one.db_host}"
}
