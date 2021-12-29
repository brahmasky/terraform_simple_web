
output "web_url" {
  description = "URLs to access the web server"
  value       = module.aws_instance.web_server_url
}

output "bastion_host_public_ip" {
  description = "Public IP for bastion host"
  value       = module.aws_instance.bastion_host_public_ip
}