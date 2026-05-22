variable "instance_type" {
  description = "EC2 Instnace Type"
  type = string
  default = "t3.micro"
}

variable "instance_type_list" {
  description = "instance are in list"
  type = list(string)
  default = ["t3.micro", "t2.micro", "t3.large"]
}

variable "instance_type_map" {
  description = "instance are in map"  
  type = map(string)
  default = {
    "dev" = "t2.micro"
    "test" = "t3.micro"
    "prod" = "t3.large"
  }
}