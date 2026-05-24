variable "vpc_name" {
  type    = string
  default = "Day_2_vpc"
}

variable "Cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "Avalibility_zone" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1d"]
}

variable "private_subnets" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnets" {
  type    = list(string)
  default = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}
variable "database_subnets" {
  type    = list(string)
  default = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}


