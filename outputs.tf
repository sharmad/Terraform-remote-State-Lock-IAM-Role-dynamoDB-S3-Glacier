
output "state_bucket" {
  value = "${aws_s3_bucket.state_bucket.id}"
}

output "state_logs_bucket" {
  value = "${aws_s3_bucket.logs_bucket.id}"
}

output "state_lock_dynamodb_table" {
  value = "${aws_dynamodb_table.terraform_state_lock.id}"
}
