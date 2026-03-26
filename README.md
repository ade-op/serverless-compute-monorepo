🟦 Serverless Compute Monorepo

This project simulates a production-style serverless event-driven pipeline using AWS and Terraform.

🧠 Architecture
S3 → Ingest Lambda → SQS → Worker Lambda → DynamoDB
Flow:
A file is uploaded to an S3 bucket
S3 triggers the ingest Lambda
The ingest Lambda sends a message to SQS
The worker Lambda processes the message
Results are stored in DynamoDB
⚙️ Technologies Used
AWS Lambda
Amazon SQS (with DLQ)
Amazon S3
Amazon DynamoDB
Terraform (modular infrastructure)
GitHub Actions (CI/CD)
📁 Project Structure
modules/
  s3/
  sqs/
  dynamodb/
  iam/
  lambda/

environments/
  dev/
  prod/

app/
  ingest_lambda/
  worker_lambda/

scripts/
  package_lambdas.sh
🚀 How to Deploy
# package lambda functions
./scripts/package_lambdas.sh

# deploy infrastructure
cd environments/dev
terraform init
terraform apply
🧪 How to Test
echo "hello from ade" > testfile.txt
aws s3 cp testfile.txt s3://<your-bucket-name>
🔍 Observability
CloudWatch logs used to verify Lambda execution
SQS metrics used to monitor message flow
DynamoDB used to confirm processed results
📌 Features
Modular Terraform design
Environment separation (dev / prod)
Event-driven architecture
Asynchronous processing with SQS
Dead Letter Queue (DLQ) support
🚀 Future Improvements (Version 2)
Add AWS Glue for data transformation
Store processed data in a separate S3 bucket
Add GitHub Actions for Terraform validation
Introduce failure testing and DLQ validation
