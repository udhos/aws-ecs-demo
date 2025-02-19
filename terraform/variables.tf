
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

variable "dns_ttl_seconds" {
  default = 20
}

variable "enable_execute_command" {
  default = true
}

variable "assign_public_ip" {
  default = true
}

variable "groupcache_version" {
  default = "2"
}

variable "min_capacity" {
  default = 2
}

variable "max_capacity" {
  default = 4
}