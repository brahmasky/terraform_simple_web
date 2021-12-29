# ============
# Create S3 bucket for terraform remote state
# ============
resource "aws_s3_bucket" "terraform_state" {
  bucket = var.s3_bucket_name
  versioning {
    enabled = true
  }

  # lifecycle {
  #   prevent_destroy = true
  # }
}

# ============
# enable state locking via dynamodb table
# ============
resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "app-state"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

### enforcing server side encrytpion
# resource "aws_s3_bucket_policy" "terraform_state" {
#   bucket = "${aws_s3_bucket.terraform_state.id}"
#   policy =<<EOF
# {
#   "Version": "2012-10-17",
#   "Id": "RequireEncryption",
#    "Statement": [
#     {
#       "Sid": "RequireEncryptedTransport",
#       "Effect": "Deny",
#       "Action": ["s3:*"],
#       "Resource": ["arn:aws:s3:::${aws_s3_bucket.terraform_state.bucket}/*"],
#       "Condition": {
#         "Bool": {
#           "aws:SecureTransport": "false"
#         }
#       },
#       "Principal": "*"
#     },
#     {
#       "Sid": "RequireEncryptedStorage",
#       "Effect": "Deny",
#       "Action": ["s3:PutObject"],
#       "Resource": ["arn:aws:s3:::${aws_s3_bucket.terraform_state.bucket}/*"],
#       "Condition": {
#         "StringNotEquals": {
#           "s3:x-amz-server-side-encryption": "AES256"
#         }
#       },
#       "Principal": "*"
#     }
#   ]
# }
# EOF
# }

# ============
# generate backend config file to be used for simple_web_deploy module
# ============
resource "local_file" "s3_backend_config" {
  content  = <<-EOT
    bucket = "${aws_s3_bucket.terraform_state.bucket}"
    key = "${var.s3_state_file_key}"
    region = "${var.aws_region}"
    profile = "terraform-user-profile"
  EOT
  filename = "${path.module}/../simple_web_deploy/files/s3_backend_config"

}

# ============
# generate an IAM user with required permissions to deploy the simple web
# ============
resource "aws_iam_user" "terraform_user" {
  name = var.terraform_user_name
}

data "aws_iam_policy_document" "cicd_policy_document" {
  # statement {
  #   actions   = ["s3:ListAllMyBuckets"]
  #   resources = ["arn:aws:s3:::*"]
  #   effect = "Allow"
  # }
  statement {
    actions   = ["s3:*"]
    resources = [aws_s3_bucket.terraform_state.arn, "${aws_s3_bucket.terraform_state.arn}/*"]
    effect    = "Allow"
  }
  statement {
    actions   = ["ec2:*"]
    resources = ["*"]
    effect    = "Allow"
  }
  statement {
    actions   = ["elasticloadbalancing:*"]
    resources = ["*"]
    effect    = "Allow"
  }
  statement {
    actions   = ["autoscaling:*"]
    resources = ["*"]
    effect    = "Allow"
  }
  statement {
    actions   = ["cloudwatch:*"]
    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "cicd_policy" {
  name        = "terraform-cicd-policy"
  description = "terraform cicd policy"
  policy      = data.aws_iam_policy_document.cicd_policy_document.json
}

resource "aws_iam_user_policy_attachment" "attachment" {
  user       = aws_iam_user.terraform_user.name
  policy_arn = aws_iam_policy.cicd_policy.arn
}

resource "aws_iam_access_key" "cicd_user_access_key" {
  user = aws_iam_user.terraform_user.name
  # use pgp_key to encrypt the access key if needed
  pgp_key = var.pgp_key_enabled == true ? "keybase:${var.keybase_io_username}" : ""
}