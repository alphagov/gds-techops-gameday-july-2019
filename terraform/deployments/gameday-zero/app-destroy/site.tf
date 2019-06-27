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

module "app_deployment_one" {
  source = "../../../modules/app-destroy"

  provider_role_arn   = "arn:aws:iam::532889539897:role/bootstrap"
  provider_role_alias = "one"
}
