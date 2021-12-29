
output "web_server_url" {
  description = "The not so pretty URL for web server"
  value       = "http://${aws_alb.web_server_alb.dns_name}"
}

output "bastion_host_public_ip" {
  description = "Public IP for bastion host"
  value       = aws_instance.bastion_host.public_ip
}