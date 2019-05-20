terraform {
  backend "s3" {
    bucket = "gds-tech-ops-gameday-zero-tfstate"
    key    = "controller.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {}

module "controller" {
  source = "../../../modules/controller"

  root_domain = "game.gds-reliability.engineering"
  subdomain   = "zero"
}
