terraform {
  # Comment out when bootstrapping
  backend "s3" {
    bucket = "gds-tech-ops-gameday-zero-tfstate"
    key    = "account.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  region= "eu-west-2"
}

module "state_bucket" {
  source = "../../../modules/state-bucket"

  bucket_name = "gds-tech-ops-gameday-zero-tfstate"
}
