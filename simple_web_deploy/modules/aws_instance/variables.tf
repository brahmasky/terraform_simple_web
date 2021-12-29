
variable "vpc_id" {
  description = "VPC ID"
}

variable "public_subnets" {
  description = "a list of public subnets with availability zone name as key"
}

variable "private_subnets" {
  description = "a list of private subnets with availability zone name as key"
}

variable "ec2_instance_type" {
  description = "Type of EC2 instance"
  type        = string
}

variable "web_server_ssh_key" {
  description = "SSH key name for web server, pre-populated on AWS"
}

variable "web_server_alb_sg_id" {
  description = "ID for ALB securty group"
  type        = string
}

variable "web_server_sg_id" {
  description = "ID for web server securty group"
  type        = string
}

variable "bastion_host_sg_id" {
  description = "ID for bastion host securty group"
  type        = string
}

variable "web_server_count_per_az" {
  description = "instance count per each availability zone"
  type        = number
}

variable "web_server_namespace" {
  description = "namespace for the web servers in launch template and auto scaling group"
  type        = string
}

variable "az_names" {
  description = "list of az names in the region"
}