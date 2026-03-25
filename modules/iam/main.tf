resource "aws_iam_role" "ingest_lambda_role" {
  name = "job-sim-${var.environment}-ingest-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role" "worker_lambda_role" {
  name = "job-sim-${var.environment}-worker-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ingest_basic" {
  role       = aws_iam_role.ingest_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "worker_basic" {
  role       = aws_iam_role.worker_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "ingest_sqs_policy" {
  name = "job-sim-${var.environment}-ingest-sqs-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = ["sqs:SendMessage"]
      Effect = "Allow"
      Resource = var.queue_arn
    }]
  })
}

resource "aws_iam_policy" "worker_ddb_policy" {
  name = "job-sim-${var.environment}-worker-ddb-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "dynamodb:PutItem",
        "dynamodb:UpdateItem"
      ]
      Effect = "Allow"
      Resource = var.table_arn
    }]
  })
}

resource "aws_iam_policy" "worker_sqs_policy" {
  name = "job-sim-${var.environment}-worker-sqs-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes",
        "sqs:GetQueueUrl"
      ]
      Effect = "Allow"
      Resource = var.queue_arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ingest_sqs_attach" {
  role       = aws_iam_role.ingest_lambda_role.name
  policy_arn = aws_iam_policy.ingest_sqs_policy.arn
}

resource "aws_iam_role_policy_attachment" "worker_ddb_attach" {
  role       = aws_iam_role.worker_lambda_role.name
  policy_arn = aws_iam_policy.worker_ddb_policy.arn
}

resource "aws_iam_role_policy_attachment" "worker_sqs_attach" {
  role       = aws_iam_role.worker_lambda_role.name
  policy_arn = aws_iam_policy.worker_sqs_policy.arn
}