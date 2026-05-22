output "for_loop_inst_list" {
    description = "for loop using list"  
    value = [for inst in aws_instance.my_instance: inst.public_dns]
}

output "for_loop_inst_map" {
    description = "here loop using for map"
    value = {for inst in aws_instance.my_instance: inst.id => inst.public_dns}  
}

output "for_loop_inst_map_advance" {
    description = "here loop for advance map"
    value = {for c, inst in aws_instance.my_instance: c => inst.public_dns}  
}

output "legacy_splat_instance_publicdns" {
  description = "Legacy Splat Expression"
  value = aws_instance.my_instance.*.public_dns
}  

# Output Latest Generalized Splat Operator - Returns the List
output "latest_splat_instance_publicdns" {
  description = "Generalized Splat Expression"
  value = aws_instance.my_instance[*].public_dns
}
