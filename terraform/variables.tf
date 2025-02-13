
variable "vpc_id" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "cidr_blocks" {
  type = list(string)
}

variable "region" {
  default = "us-east-1"
}