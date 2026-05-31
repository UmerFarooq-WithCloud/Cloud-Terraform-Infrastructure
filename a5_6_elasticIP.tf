resource "aws_eip" "elastic_ip" {

  depends_on = [module.vpc, module.ec2_instance_for_public]
  instance   = module.ec2_instance_for_public.id

  domain = "vpc"
  tags   = local.common_tags
}

