# ============
# Store state file on remote S3 bucket
# ============
terraform {
  backend "s3" {}
}

# ============
# calling aws_networking module to provision networking infrastructure
# ============
module "aws_networking" {
  source = "./modules/aws_networking"

  vpc_cidr_block       = var.vpc_cidr_block
  web_server_namespace = var.web_server_namespace
  subnet_cidr_blocks   = var.subnet_cidr_blocks
}

# ============
# calling aws_instance module to provison the web servers with target group and application load balancer
# ============
module "aws_instance" {
  source = "./modules/aws_instance"

  vpc_id                  = module.aws_networking.web_server_vpc_id
  public_subnets          = module.aws_networking.web_server_public_subnets
  private_subnets         = module.aws_networking.web_server_private_subnets
  web_server_namespace    = var.web_server_namespace
  ec2_instance_type       = var.ec2_instance_type
  web_server_ssh_key      = var.web_server_ssh_key
  web_server_sg_id        = module.aws_networking.web_server_sg_id
  web_server_alb_sg_id    = module.aws_networking.web_server_alb_sg_id
  bastion_host_sg_id      = module.aws_networking.bastion_host_sg_id
  web_server_count_per_az = var.web_server_count_per_az
  az_names                = module.aws_networking.az_names


}