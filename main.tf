provider "aws" {
  region = var.region
  profile = var.aws_profile
  shared_config_files = ["/Users/shui/.aws/config", "/Users/shui/.aws/credentials"]
}

module "vpc" {
  source = "./modules/vpc"

  name_prefix = var.name_prefix
  vpc_cidr_block = var.vpc_cidr_block
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

locals {
  vpc_id = module.vpc.vpc_id
}

# Network ACL
module "default_acl" {
  source = "./modules/acl"
  vpc_id = local.vpc_id
  depends_on = [module.vpc]

  network_acl_rules   = [
    { cidr_block = "0.0.0.0/0", protocol = 6, rule_action          = "allow", rule_number          = 102, egress               = false },
    { cidr_block  = "8.8.4.4/32", protocol = 6, rule_action          = "deny", rule_number          = 105, egress               = true }
  ]
}
