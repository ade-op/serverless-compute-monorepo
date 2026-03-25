terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "s3" {
  source      = "../../modules/s3"
  bucket_name = "job-sim-dev-ade-input-bucket"
  environment = var.environment
}

module "sqs" {
  source      = "../../modules/sqs"
  queue_name  = "job-sim-dev-main-queue"
  dlq_name    = "job-sim-dev-dlq"
  environment = var.environment
}

module "dynamodb" {
  source      = "../../modules/dynamodb"
  table_name  = "job-sim-dev-status-table"
  environment = var.environment
}

module "iam" {
  source      = "../../modules/iam"
  environment = var.environment
  queue_arn   = module.sqs.queue_arn
  table_arn   = module.dynamodb.table_arn
}

module "ingest_lambda" {
  source           = "../../modules/lambda"
  function_name    = "job-sim-dev-ingest"
  role_arn         = module.iam.ingest_lambda_role_arn
  handler          = "handler.lambda_handler"
  runtime          = "python3.12"
  filename         = "../../build/ingest_lambda.zip"
  source_code_hash = filebase64sha256("../../build/ingest_lambda.zip")

  environment_variables = {
    QUEUE_URL = module.sqs.queue_url
  }
}

module "worker_lambda" {
  source           = "../../modules/lambda"
  function_name    = "job-sim-dev-worker"
  role_arn         = module.iam.worker_lambda_role_arn
  handler          = "handler.lambda_handler"
  runtime          = "python3.12"
  filename         = "../../build/worker_lambda.zip"
  source_code_hash = filebase64sha256("../../build/worker_lambda.zip")

  environment_variables = {
    TABLE_NAME = module.dynamodb.table_name
  }
}

resource "aws_lambda_permission" "allow_s3_to_invoke_ingest" {
  statement_id  = "AllowS3InvokeIngest"
  action        = "lambda:InvokeFunction"
  function_name = module.ingest_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = module.s3.bucket_arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = module.s3.bucket_id

  lambda_function {
    lambda_function_arn = module.ingest_lambda.lambda_arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3_to_invoke_ingest]
}

resource "aws_lambda_event_source_mapping" "worker_sqs_mapping" {
  event_source_arn = module.sqs.queue_arn
  function_name    = module.worker_lambda.lambda_arn
  batch_size       = 1
}