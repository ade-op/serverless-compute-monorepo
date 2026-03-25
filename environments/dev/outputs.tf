output "bucket_name" {
  value = module.s3.bucket_name
}

output "queue_url" {
  value = module.sqs.queue_url
}

output "table_name" {
  value = module.dynamodb.table_name
}

output "ingest_lambda_name" {
  value = module.ingest_lambda.function_name
}

output "worker_lambda_name" {
  value = module.worker_lambda.function_name
}