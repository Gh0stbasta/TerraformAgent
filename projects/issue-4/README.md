# Event-Driven Architecture: API Gateway -> SQS -> Lambda

This project demonstrates a minimal event-driven architecture on AWS using Terraform.

## Architecture

```
HTTP POST → API Gateway → SQS Queue → Lambda Function
```

## Components

- **API Gateway HTTP API**: Accepts POST requests at `/messages` endpoint
- **SQS Queue**: Buffers messages from API Gateway
- **Lambda Function**: Processes messages from SQS queue
- **IAM Roles**: Minimal permissions for API Gateway → SQS and Lambda → SQS

## Deployment

1. Ensure you have AWS credentials configured
2. Run the following commands:

```bash
terraform init
terraform plan
terraform apply
```

## Usage

After deployment, get the API endpoint from the output:

```bash
terraform output api_endpoint
```

Send a message via curl:

```bash
curl -X POST "https://your-api-id.execute-api.eu-central-1.amazonaws.com/messages" \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello, World!"}'
```

Check CloudWatch logs for the Lambda function to see processed messages.

## Cleanup

```bash
terraform destroy
```

## Features

- ✅ Under 100 lines of Terraform code
- ✅ Minimal IAM permissions
- ✅ Inline Lambda handler (Node.js)
- ✅ Event-driven architecture demonstration
- ✅ Automatic SQS → Lambda triggering