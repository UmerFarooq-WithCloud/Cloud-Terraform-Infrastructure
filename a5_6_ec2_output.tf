output "public_instance_id" {
  description = "Public instance id"
  value       = module.ec2_instance_for_public.id
}

output "public_instance_ip" {
  description = "ip address for instance"
  value       = module.ec2_instance_for_public.public_ip
}

output "private_instance_id_for_app1" {
  description = "private instance id"
  #   value       = module.ec2_instance_for_private.id
  value = [for inst1 in module.ec2_instance_for_private_app1 : inst1.id]
}

output "private_instance_id_for_app2" {
  description = "private instance ip "
  #   value       = module.ec2_instance_for_private.public_ip
  value = [for inst2 in module.ec2_instance_for_private_app2 : inst2.id]
}


output "ec2_private_ip_app1" {
  description = "List of private IP addresses assigned to the instances"
  value       = [for ec2private in module.ec2_instance_for_private_app1 : ec2private.private_ip]
}


output "ec2_private_ip_app2" {
  description = "List of private IP addresses assigned to the instances"
  value       = [for ec2private in module.ec2_instance_for_private_app2 : ec2private.private_ip]
}
