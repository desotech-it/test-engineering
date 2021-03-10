provider "aws" {
  region = var.aws_region
}


module "network" {
  source         = "./modules/network"
  vpc_cidr_block = var.vpc_cdr_block
  vpc_name       = var.vpc_name
  aws_region     = var.aws_region
}

module "load_balancer" {
  source             = "./modules/load_balancer"
  vpc_id             = module.network.vpc_id
  name               = var.load_balancer_name
  public_subnet_ids  = module.network.public_subnet_ids
  private_subnet_ids = module.network.private_subnet_ids
  aws_region         = var.aws_region
}
