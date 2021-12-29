variable "aws_profile" {
  description = "an aws profile name stored in ~/.aws/credentials, with administrator permissions for initialisation task"
  type        = string
  default     = "terraform-admin-profile"
}

variable "aws_region" {
  description = "The default aws region for the deployment"
  type        = string
  default     = "ap-southeast-2"
}

variable "s3_bucket_name" {
  description = "S3 bucket name"
  type        = string
  default     = "terraform-remote-state-for-simple-web"
}

variable "s3_state_file_key" {
  description = "path to the state file in s3"
  type        = string
  default     = "simple-web-hosting-tfstate"
}

variable "terraform_user_name" {
  description = "terraform user name"
  type        = string
  default     = "terraform-user"
}

variable "pgp_key_enabled" {
  description = "A flag to enable pgp_key encryption for aws access key"
  type        = bool
  default     = false
}

variable "keybase_io_username" {
  description = "keybase (keybase.io) username to be used for access key encryption"
  type        = string
  default     = "test"
}