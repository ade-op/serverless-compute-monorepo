resource "aws_sqs_queue" "dlq" {
  name = var.dlq_name

  tags = {
    Environment = var.environment
    Project     = "job-sim-lab"
  }
}

resource "aws_sqs_queue" "main" {
  name = var.queue_name

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 3
  })

  tags = {
    Environment = var.environment
    Project     = "job-sim-lab"
  }
}