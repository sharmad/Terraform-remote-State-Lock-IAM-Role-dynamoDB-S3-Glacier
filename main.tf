provider "aws" {
  region = "${var.aws_region}"
}

# bucket for storing terraform state logs, and archiving to standard_ia and glacier after 30 days and 60 days respectively
resource "aws_s3_bucket" "logs_bucket" {
  bucket              = "terraform-state-${var.bucket-suffix}-logs"
  acl                 = "log-delivery-write"
  acceleration_status = "Enabled"

  lifecycle_rule {
    id      = "logs"
    enabled = true

    prefix  = "logs/"
    tags {
      "rule"      = "logs"
      "autoclean" = "true"
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }

    expiration {
      days = 90
    }
  }

  tags {
    Name = "Terraform State Logging"
    Environment = "${var.env}"
  }
}


# bucket for storing terraform state
resource "aws_s3_bucket" "state_bucket" {
  bucket              = "terraform-state-${var.bucket-suffix}"
  acl                 = "private"
  acceleration_status = "Enabled"

  tags {
    Name = "Terraform remote state bucket"
    Environment = "${var.env}"
  }

  versioning {
    enabled = true
  }

  logging {
    target_bucket = "${aws_s3_bucket.logs_bucket.id}"
    target_prefix = "logs/"
  }

  lifecycle {
    prevent_destroy = true
  }

}

# get IAM role arn
data "aws_iam_role" "role" {
  name = "${var.role}"
}

# grant IAM role access to the bucket
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = "${aws_s3_bucket.state_bucket.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal":{
        "AWS": "${data.aws_iam_role.role.arn}"
      },
      "Action": [ "s3:*" ],
      "Resource": [
        "${aws_s3_bucket.state_bucket.arn}",
        "${aws_s3_bucket.state_bucket.arn}/*"
        "${aws_s3_bucket.logs_bucket.arn}",
        "${aws_s3_bucket.logs_bucket.arn}/*"
      ]
    }
  ]
}
EOF
}


# Create a DynamoDB state lock table
resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "${var.dynamodb_state_lock_table}"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags {
    Name = "DynamoDB table for state locking"
    Environment = "${var.env}"
  }
}
