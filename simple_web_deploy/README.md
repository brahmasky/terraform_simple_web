# simple_web_deploy
This module deploys the networking infrastructure and ec2 instances for the **Simple Web** 

- aws_networking module deploy the networking infrastructure 
- aws_instnace module deploy the ec2 insances managed by auto scaling group 

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_instance"></a> [aws\_instance](#module\_aws\_instance) | ./modules/aws_instance | n/a |
| <a name="module_aws_networking"></a> [aws\_networking](#module\_aws\_networking) | ./modules/aws_networking | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The default aws region for the deployment | `string` | n/a | yes |
| <a name="input_ec2_instance_type"></a> [ec2\_instance\_type](#input\_ec2\_instance\_type) | Type of EC2 instance | `string` | n/a | yes |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | S3 bucket name | `string` | n/a | yes |
| <a name="input_s3_state_file_key"></a> [s3\_state\_file\_key](#input\_s3\_state\_file\_key) | path to the state file in s3 | `string` | n/a | yes |
| <a name="input_subnet_cidr_blocks"></a> [subnet\_cidr\_blocks](#input\_subnet\_cidr\_blocks) | CIDR blocks for private/public subnets in each AZ | `map(any)` | n/a | yes |
| <a name="input_terraform_user_profile"></a> [terraform\_user\_profile](#input\_terraform\_user\_profile) | terraform user profile name stored in ~/.aws/credentials | `string` | n/a | yes |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | CIDR block for VPC | `string` | n/a | yes |
| <a name="input_web_server_count_per_az"></a> [web\_server\_count\_per\_az](#input\_web\_server\_count\_per\_az) | instance count per each availability zone | `number` | n/a | yes |
| <a name="input_web_server_namespace"></a> [web\_server\_namespace](#input\_web\_server\_namespace) | namespace used for the launch template and auto scaling group | `string` | n/a | yes |
| <a name="input_web_server_ssh_key"></a> [web\_server\_ssh\_key](#input\_web\_server\_ssh\_key) | SSH key name for web server, pre-populated on AWS | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bastion_host_public_ip"></a> [bastion\_host\_public\_ip](#output\_bastion\_host\_public\_ip) | Public IP for bastion host |
| <a name="output_web_url"></a> [web\_url](#output\_web\_url) | URLs to access the web server |
<!-- END_TF_DOCS -->