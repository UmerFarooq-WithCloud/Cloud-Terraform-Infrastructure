data "aws_route53_zone" "My_route53" {
  name = "devsecflow.me"

}

output "hosted_zone_id" {
  description = "hosted zone id for desired hosted zone"
  value       = data.aws_route53_zone.My_route53.zone_id
}

output "hosted_zone_name" {
  description = "hosted zone name for desired hosted zone"
  value       = data.aws_route53_zone.My_route53.name
}
