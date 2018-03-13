variable "aws_region" {
  type = "string"
  default = "eu-west-1"
}

variable "env" {
  type        = "string"
  description = "Name of the environment. Example: prod"
}

# IAM role to access the terraform remote state
variable "role" {}

variable "dynamodb_state_lock_table" {
  type        = "string"
  description = "DynamoDB table name for terraform lock."
}
