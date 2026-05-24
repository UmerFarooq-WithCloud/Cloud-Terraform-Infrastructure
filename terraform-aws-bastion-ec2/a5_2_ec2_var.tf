variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "private_instance_count" {
  type    = number
  default = 2

}

variable "key_pair" {
  type    = string
  default = "titan_attack"
}




