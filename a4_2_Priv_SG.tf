module "private_instance_SG" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.1"

  name   = "private instance security group"
  vpc_id = module.vpc.vpc_id

  #ingress rule 
  ingress_rules       = ["ssh-tcp", "http-80-tcp"]
  ingress_cidr_blocks = [module.vpc.vpc_cidr_block]
  #egress rule
  egress_rules = ["all-all"]
}
