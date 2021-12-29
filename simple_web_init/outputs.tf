output "aws_access_key_id" {
  description = "Access key ID for the cicd user"
  value       = aws_iam_access_key.cicd_user_access_key.id
}

output "aws_secret_access_key" {
  description = "Access key for the cicd user"
  sensitive   = true
  value       = aws_iam_access_key.cicd_user_access_key.secret
}

output "aws_secret_access_key_encrypted" {
  description = "Access key for the cicd user encrypted by pgp key"
  value       = aws_iam_access_key.cicd_user_access_key.encrypted_secret
}