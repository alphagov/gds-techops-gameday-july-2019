locals {
  gds_cidrs = [
    "0.0.0.0/0",
  ]
}

output "gds_cidr_blocks" {
  value = "${local.gds_cidrs}"
}
