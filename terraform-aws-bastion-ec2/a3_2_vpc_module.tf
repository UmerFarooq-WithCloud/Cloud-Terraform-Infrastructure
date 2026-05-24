module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.6.1"

  name = var.vpc_name
  cidr = var.Cidr_block
  #Avalibility zones
  azs = var.Avalibility_zone

  #subnets 
  private_subnets  = var.private_subnets
  public_subnets   = var.public_subnets
  database_subnets = var.database_subnets

  #creating route tables for database
  create_database_subnet_group       = true
  create_database_subnet_route_table = true

  #create gateway for public subnet
  enable_vpn_gateway = true

  #create nat gateway for private subnet
  enable_nat_gateway = true
  single_nat_gateway = true

  # enable dns host
  enable_dns_hostnames = true
  enable_dns_support   = true


}
