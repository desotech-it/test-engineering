# Crea le seguenti variabili
# name
# public_subnet_ids
# private_subnet_ids
# vpc_id

variable "vpc_id" {
  type = string
}

variable "name" {
  type        = string
  description = "Load Balancer Name"
}

variable "public_subnet_ids" {
  type = map(string)
}

variable "private_subnet_ids" {
  type = map(string)
}
variable "aws_region"{
    type = string
}