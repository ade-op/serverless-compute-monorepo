import json
import os
import boto3

sqs = boto3.client("sqs")
QUEUE_URL = os.environ["QUEUE_URL"]

def lambda_handler(event, context):
    print("Received event:", json.dumps(event))

    for record in event.get("Records", []):
        bucket = record["s3"]["bucket"]["name"]
        key = record["s3"]["object"]["key"]

        message = {
            "bucket": bucket,
            "key": key,
            "event_name": record.get("eventName", "unknown")
        }

        sqs.send_message(
            QueueUrl=QUEUE_URL,
            MessageBody=json.dumps(message)
        )

        print(f"Sent message to SQS for {key}")

    return {
        "statusCode": 200,
        "body": json.dumps("Ingest complete")
    }