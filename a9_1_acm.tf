module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "6.3.0"

  domain_name = trimsuffix(data.aws_route53_zone.My_route53.name, ".")
  zone_id     = data.aws_route53_zone.My_route53.zone_id

  validation_method = "DNS"

  subject_alternative_names = [
    "*.devsecflow.me",

  ]

  wait_for_validation = true

  tags = {
    Name = "my-domain.com"
  }
}

output "acm_certificate_arn" {
  description = "The ARN of the certificate"
  value       = module.acm.acm_certificate_arn
}

output "validation_route53_record_fqdns" {
  description = "List of FQDNs built using the zone domain and name."
  value       = module.acm.validation_route53_record_fqdns
}
