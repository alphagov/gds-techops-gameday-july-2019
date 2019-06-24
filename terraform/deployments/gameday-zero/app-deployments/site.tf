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
    "alex.kinnane",
    "tristram.oaten",
    "oliver.chalk",
  ]

  participants_vo = [
    "alex.kinnane",
    "tristram.oaten",
    "oliver.chalk",
  ]

  # participants = [
  #   "aaron.hine",
  #   "dan.jones",
  #   "issy.long",
  #   "jonathan.glassman",
  #   "stephen.harker",
  #   "emily.labram",
  #   "veronika.kovalenkova",
  # ]

  # participants_vo = [
  #   "martin.sivorn",
  # ]
}

# module "app_deployment_two" {
#   source = "../../../modules/app-deployment"

#   provider_role_arn   = "arn:aws:iam::174281875411:role/bootstrap"
#   provider_role_alias = "two"

#   root_domain = "game.gds-reliability.engineering"
#   subdomain   = "two"
#   db_password = "${local.db_password}"

#   participants = [
#     "emily.young",
#     "deniz.genc",
#     "phil.potter",
#     "sebastian.schmie",
#     "venus.bailey",
#     "daniel.thorpe",
#     "michael.asimah",
#     "albert.massa",
#   ]

#   participants_vo = [
#     "phil.potter",
#   ]
# }

# module "app_deployment_three" {
#   source = "../../../modules/app-deployment"

#   provider_role_arn   = "arn:aws:iam::249264020656:role/bootstrap"
#   provider_role_alias = "three"

#   root_domain = "game.gds-reliability.engineering"
#   subdomain   = "three"
#   db_password = "${local.db_password}"

#   participants = [
#     "james.murphy",
#     "eliska.copland",
#     "roch.trinque",
#     "richard.barker",
#     "nicole.tinti",
#     "iain.gordan",
#     "nick.breeze",
#   ]

#   participants_vo = [
#     "andy.hunt",
#   ]
# }

# module "app_deployment_four" {
#   source = "../../../modules/app-deployment"

#   provider_role_arn   = "arn:aws:iam::365302813217:role/bootstrap"
#   provider_role_alias = "four"

#   root_domain = "game.gds-reliability.engineering"
#   subdomain   = "four"
#   db_password = "${local.db_password}"

#   participants = [
#     "jon-michael.pitt",
#     "athanasios.voutsadakis",
#     "frederick.francois",
#     "anshul.siruh",
#     "sam.crang",
#     "ravi.sachdev",
#     "leema.ahmed",
#     "rashmi.patel",
#   ]

#   participants_vo = [
#     "chirs.familoe",
#   ]
# }

# module "app_deployment_five" {
#   source = "../../../modules/app-deployment"

#   provider_role_arn   = "arn:aws:iam::885616235187:role/bootstrap"
#   provider_role_alias = "five"

#   root_domain = "game.gds-reliability.engineering"
#   subdomain   = "five"
#   db_password = "${local.db_password}"

#   participants = [
#     "patrick.sungbahadoor",
#     "sergio.navarrovalverde",
#     "sam.detnon",
#     "david.pye",
#     "gianni.howard-hole",
#     "luke.malcher",
#   ]

#   participants_vo = [
#     "chirs.familoe",
#   ]
# }

# module "app_deployment_six" {
#   source = "../../../modules/app-deployment"

#   provider_role_arn   = "arn:aws:iam::384095500471:role/bootstrap"
#   provider_role_alias = "six"

#   root_domain = "game.gds-reliability.engineering"
#   subdomain   = "six"
#   db_password = "${local.db_password}"

#   participants = [
#     "thet.naing",
#     "alex.monk",
#     "sebastian.szypowicz",
#     "mohamed.deerow",
#     "shaneek.glispie",
#     "rumman.amin",
#     "julia.harrison",
#   ]

#   participants_vo = [
#     "conor.glynn",
#   ]
# }

# module "app_deployment_seven" {
#   source = "../../../modules/app-deployment"

#   provider_role_arn   = "arn:aws:iam::796489217542:role/bootstrap"
#   provider_role_alias = "seven"

#   root_domain = "game.gds-reliability.engineering"
#   subdomain   = "seven"
#   db_password = "${local.db_password}"

#   participants = [
#     "ian.pearl",
#     "paul.dougan",
#     "andy.paine",
#     "michael.mokrysz",
#     "thierry.ndangi",
#     "ben.andrews",
#   ]

#   participants_vo = [
#     "russell.howe",
#   ]
# }

output "database_password" {
  value = "${local.db_password}"
}

output "deployment_one_db_host" {
  value = "${module.app_deployment_one.db_host}"
}
