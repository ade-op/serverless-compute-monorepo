output "ingest_lambda_role_arn" {
  value = aws_iam_role.ingest_lambda_role.arn
}

output "worker_lambda_role_arn" {
  value = aws_iam_role.worker_lambda_role.arn
}