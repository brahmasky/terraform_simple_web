variable "terraform_user_profile" {
  description = "terraform user profile name stored in ~/.aws/credentials"
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket name"
  type        = string
}

variable "s3_state_file_key" {
  description = "path to the state file in s3"
  type        = string
}
variable "aws_region" {
  description = "The default aws region for the deployment"
  type        = string
}

variable "subnet_cidr_blocks" {
  description = "CIDR blocks for private/public subnets in each AZ"
  type        = map(any)
}

variable "web_server_ssh_key" {
  description = "SSH key name for web server, pre-populated on AWS"
  type        = string
}

variable "ec2_instance_type" {
  description = "Type of EC2 instance"
  type        = string
}

variable "web_server_namespace" {
  description = "namespace used for the launch template and auto scaling group"
  type        = string
}

variable "web_server_count_per_az" {
  description = "instance count per each availability zone"
  type        = number
}