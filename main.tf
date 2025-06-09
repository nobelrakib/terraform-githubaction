provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "./modules/vpc"

  environment           = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnets_cidr  = var.public_subnets_cidr
  private_subnets_cidr = var.private_subnets_cidr
  database_subnets_cidr = var.database_subnets_cidr
  availability_zones   = var.availability_zones
}

module "keypair" {
  source = "./modules/keypair"

  environment = var.environment
}

module "ec2" {
  source = "./modules/ec2"

  environment        = var.environment
  vpc_id            = module.vpc.vpc_id
  vpc_cidr          = var.vpc_cidr
  public_subnet_id  = module.vpc.subnet_ids.public[0]
  private_subnet_id = module.vpc.subnet_ids.private[0]
  database_subnet_id = module.vpc.subnet_ids.database[0]
  key_name          = module.keypair.key_name
} 