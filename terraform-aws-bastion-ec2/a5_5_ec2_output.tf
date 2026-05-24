output "public_instance_id" {
  description = "Public instance id"
  value       = module.ec2_instance_for_public.id
}

output "public_instance_ip" {
  description = "ip address for instance"
  value       = module.ec2_instance_for_public.public_ip
}

output "private_instance_id" {
  description = "private instance id"
  #   value       = module.ec2_instance_for_private.id
  value = [for inst1 in module.ec2_instance_for_private : inst1.id]
}

output "private_instance_ip" {
  description = "private instance ip "
  #   value       = module.ec2_instance_for_private.public_ip
  value = [for inst2 in module.ec2_instance_for_private : inst2.private_ip]
}

