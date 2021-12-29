# aws_instance

This module leverage auto scaling group to provision the web servers in high availability mode
- launch template with user data script to install the apache web server
- auto scaling group with one web server per az
- application load balancer and target group
