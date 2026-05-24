module "public_instance_SG" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.1"

  name   = "Public_ec2_security_group"
  vpc_id = module.vpc.vpc_id

  # for inbound traffic 
  ingress_rules       = ["ssh-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]

  # for output traffic 
  egress_rules = ["all-all"]
  tags         = local.common_tags
}
