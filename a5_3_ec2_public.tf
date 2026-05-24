module "ec2_instance_for_public" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "public_instance"

  instance_type = var.instance_type
  ami           = data.aws_ami.amzlinux2.id
  key_name      = var.key_pair
  #   monitoring  = true
  vpc_security_group_ids = [module.public_instance_SG.security_group_id]
  subnet_id              = module.vpc.public_subnets[0]

  tags = local.common_tags
}

