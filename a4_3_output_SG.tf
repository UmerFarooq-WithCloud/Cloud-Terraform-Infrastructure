output "public_sg_group_id" {
  description = "The ID of the security group"
  #value       = module.public_bastion_sg.this_security_group_id
  value = module.public_instance_SG.security_group_id
}

## public_bastion_sg_group_vpc_id
output "public_sg_group_vpc_id" {
  description = "The VPC ID"
  # value       = module.public_bastion_sg.this_security_group_vpc_id
  value = module.public_instance_SG.security_group_vpc_id
}

output "private_sg_group_id" {
  description = "The ID of the security group"
  #value       = module.private_sg.this_security_group_id
  value = module.private_instance_SG.security_group_id
}

## private_sg_group_vpc_id
output "private_sg_group_vpc_id" {
  description = "The VPC ID"
  #value       = module.private_sg.this_security_group_vpc_id
  value = module.private_instance_SG.security_group_vpc_id
}
