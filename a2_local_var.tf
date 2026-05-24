locals {
  owners      = var.busniess_division
  environment = var.envoirment
  name        = "${var.busniess_division}-${var.envoirment}"
  #name = "${local.owners}-${local.environment}"
  common_tags = {
    owners      = local.owners
    environment = local.environment
  }
}
