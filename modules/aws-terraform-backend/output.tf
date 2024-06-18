output "dynamodb_lock_stream_arn" {
  value = aws_dynamodb_table.tf_backend_state_lock_table.*.stream_arn
}

output "dynamodb_lock_table_arn" {
  value = aws_dynamodb_table.tf_backend_state_lock_table.*.arn
}

output "dynamodb_lock_table_name" {
  value = aws_dynamodb_table.tf_backend_state_lock_table.*.id
}

output "dynamodb_lock_stream_label" {
  value = aws_dynamodb_table.tf_backend_state_lock_table.*.stream_label
}

output "s3_backend_bucket_name" {
  value = join(
    "",
    aws_s3_bucket.tf_backend_bucket.*.id,
    aws_s3_bucket.tf_backend_bucket.*.id,
  )
}
