variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
}

variable "web_server_namespace" {
  description = "namespace used for the launch template and auto scaling group"
  type        = string
}

variable "subnet_cidr_blocks" {
  description = "CIDR blocks for private/public subnets in each AZ"
  type        = map(any)
}