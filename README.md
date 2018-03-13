# Module to configure Terraform remote State, locking, archiving via lifecycle policies and only grant specific IAM role access to the state

## Features
* Terraform remote State in S3
* Locking with dynamoDB
* Archiving logs to standard-IA, Glacier via lifecycle policies
* Access to the remote state to only specific IAM Role


# Inputs
| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| region | region | string | `eu-west-1` | no |
| environment | dev, staging, prod, etc | string | - | yes |
| bucket-suffix | Suffix to be used in the bucket name, like `terraform-state-{bucket-suffix}` | string | - | yes |
| role | IAM role to access the terraform remote state | string | - | yes |

# Usage

To use this module in your project, add the following to your main .tf file:

```terraform
module "tf_remote_state_lock" {
  source = "github.com/sharmad/Terraform-remote-State-Lock-IAM-Role-dynamoDB-S3-Glacier"
  version = ">= 1.0.0"

  role = "aws-env-dev-staging"

  tf_state_s3_bucket = "${var.s3_unique_bucket_name}"  

  dynamodb_state_lock_table = "${var.dynamodb_state_table_name}"
}
```

### Example with hardcoded values:

```terraform
module "tf_remote_state_lock" {
	source = "github.com/sharmad/Terraform-remote-State-Lock-IAM-Role-dynamoDB-S3-Glacier"
	version = ">= 1.0.0"  
	tf_state_s3_bucket = "a-unique-bucket-name-to-store-state"
	dynamodb_state_lock_table = "tf_state_lock"
}
```
