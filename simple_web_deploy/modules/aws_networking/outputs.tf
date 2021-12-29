
output "web_server_vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "web_server_public_subnets" {
  description = "a list of public subnets with availability zone name as key"
  value       = aws_subnet.public_subnet
}

output "web_server_private_subnets" {
  description = "a list of private subnets with availability zone name as key"
  value       = aws_subnet.private_subnet
}

output "web_server_alb_sg_id" {
  description = "ID for ALB securty group"
  value       = aws_security_group.web_server_alb_sg.id
}

output "web_server_sg_id" {
  description = "ID for web server securty group"
  value       = aws_security_group.web_server_sg.id
}

output "bastion_host_sg_id" {
  description = "ID for bastion host securty group"
  value       = aws_security_group.bastion_host_sg.id
}

output "az_names" {
  description = "list of names for the availability zone in specified region "
  value       = data.aws_availability_zones.available.names
}