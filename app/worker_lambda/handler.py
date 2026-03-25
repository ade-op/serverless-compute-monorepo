import json
import os
import boto3
from datetime import datetime, timezone

dynamodb = boto3.resource("dynamodb")
TABLE_NAME = os.environ["TABLE_NAME"]
table = dynamodb.Table(TABLE_NAME)

def lambda_handler(event, context):
    print("Received SQS event:", json.dumps(event))

    for record in event.get("Records", []):
        body = json.loads(record["body"])
        bucket = body["bucket"]
        key = body["key"]

        table.put_item(
            Item={
                "file_id": key,
                "bucket": bucket,
                "object_key": key,
                "status": "processed",
                "processed_at": datetime.now(timezone.utc).isoformat()
            }
        )

        print(f"Wrote item for {key} to DynamoDB")

    return {
        "statusCode": 200,
        "body": json.dumps("Worker complete")
    }