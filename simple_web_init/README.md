# simple_web_init
This module performs the initialisation tasks for Simple Web deployment. 

- create a S3 bucket to be used for [simple_web_deploy](../simple_web_deploy) module for remote state storage with state locking using dynamodb table
- generate a backend config file for the deploy module
- create an terraform user with necessary permissions to be used by the **Simple Web** deployment
- optionally (`pgp_key_enabled` in [varriables](./variables.tf)), use pgp_key to encrypte the access key of the terraform user as per [this article](https://www.linkedin.com/pulse/secret-management-w-key-base-terraform-easy-way-jrtlabs/)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.70.0 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.1.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_dynamodb_table.terraform_state_lock](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |
| [aws_iam_access_key.cicd_user_access_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_access_key) | resource |
| [aws_iam_policy.cicd_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_user.terraform_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_iam_user_policy_attachment.attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy_attachment) | resource |
| [aws_s3_bucket.terraform_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [local_file.s3_backend_config](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [aws_iam_policy_document.cicd_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_profile"></a> [aws\_profile](#input\_aws\_profile) | an aws profile name stored in ~/.aws/credentials, with administrator permissions for initialisation task | `string` | `"terraform-admin-profile"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The default aws region for the deployment | `string` | `"ap-southeast-2"` | no |
| <a name="input_keybase_io_username"></a> [keybase\_io\_username](#input\_keybase\_io\_username) | keybase (keybase.io) username to be used for access key encryption | `string` | `"test"` | no |
| <a name="input_pgp_key_enabled"></a> [pgp\_key\_enabled](#input\_pgp\_key\_enabled) | A flag to enable pgp\_key encryption for aws access key | `bool` | `false` | no |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | S3 bucket name | `string` | `"terraform-remote-state-for-simple-web"` | no |
| <a name="input_s3_state_file_key"></a> [s3\_state\_file\_key](#input\_s3\_state\_file\_key) | path to the state file in s3 | `string` | `"simple-web-hosting-tfstate"` | no |
| <a name="input_terraform_user_name"></a> [terraform\_user\_name](#input\_terraform\_user\_name) | terraform user name | `string` | `"terraform-user"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_access_key_id"></a> [aws\_access\_key\_id](#output\_aws\_access\_key\_id) | Access key ID for the cicd user |
| <a name="output_aws_secret_access_key"></a> [aws\_secret\_access\_key](#output\_aws\_secret\_access\_key) | Access key for the cicd user |
| <a name="output_aws_secret_access_key_encrypted"></a> [aws\_secret\_access\_key\_encrypted](#output\_aws\_secret\_access\_key\_encrypted) | Access key for the cicd user encrypted by pgp key |
<!-- END_TF_DOCS -->