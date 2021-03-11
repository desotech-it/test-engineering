# Crea le seguenti variabili:
# aws_region
# vpc_cidr_block
# vpc_name
# load_balancer_name

variable "aws_region"{
    type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "vpc_name" {
  type   = string
}

variable "load_balancer_name" {
  type   = string
}