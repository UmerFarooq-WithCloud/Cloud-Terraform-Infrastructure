module "ec2_instance_for_private" {
  depends_on = [module.vpc]
  source     = "terraform-aws-modules/ec2-instance/aws"

  name = "private_instance"

  instance_type = var.instance_type
  ami           = data.aws_ami.amzlinux2.id
  key_name      = var.key_pair
  #   monitoring  = true
  vpc_security_group_ids = [module.private_instance_SG.security_group_id]
  for_each               = toset(["0", "1"])
  subnet_id              = element(module.vpc.private_subnets, tonumber(each.key))


  # count     = var.private_instance_count
  user_data = file("${path.module}/ec2_web.sh")
  tags      = local.common_tags
}



