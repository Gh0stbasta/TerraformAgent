# Event-Driven Architecture: API Gateway -> SQS -> Lambda
terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}
provider "aws" { region = "eu-central-1" }

resource "aws_sqs_queue" "event_queue" { name = "event-queue" }

data "archive_file" "lambda_zip" {
  type = "zip"
  output_path = "lambda_function.zip"
  source {
    content = "exports.handler = async (event) => { console.log('Processing messages:', event.Records.length); event.Records.forEach(r => console.log('Message:', r.body)); return { statusCode: 200 }; };"
    filename = "index.js"
  }
}

resource "aws_lambda_function" "message_processor" {
  filename = "lambda_function.zip"
  function_name = "message-processor"
  role = aws_iam_role.lambda_role.arn
  handler = "index.handler"
  runtime = "nodejs18.x"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda-sqs-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "lambda.amazonaws.com" } }]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda-sqs-policy"
  role = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { Effect = "Allow", Action = ["logs:*"], Resource = "*" },
      { Effect = "Allow", Action = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"], Resource = aws_sqs_queue.event_queue.arn }
    ]
  })
}

resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = aws_sqs_queue.event_queue.arn
  function_name = aws_lambda_function.message_processor.arn
}

resource "aws_iam_role" "api_role" {
  name = "api-sqs-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "apigateway.amazonaws.com" } }]
  })
}

resource "aws_iam_role_policy" "api_policy" {
  name = "api-sqs-policy"
  role = aws_iam_role.api_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Effect = "Allow", Action = "sqs:SendMessage", Resource = aws_sqs_queue.event_queue.arn }]
  })
}

resource "aws_apigatewayv2_api" "event_api" {
  name = "event-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "sqs_integration" {
  api_id = aws_apigatewayv2_api.event_api.id
  integration_type = "AWS_PROXY"
  integration_uri = "arn:aws:apigateway:${data.aws_region.current.name}:sqs:path/${data.aws_caller_identity.current.account_id}/${aws_sqs_queue.event_queue.name}"
  integration_method = "POST"
  credentials_arn = aws_iam_role.api_role.arn
}

resource "aws_apigatewayv2_route" "post_messages" {
  api_id = aws_apigatewayv2_api.event_api.id
  route_key = "POST /messages"
  target = "integrations/${aws_apigatewayv2_integration.sqs_integration.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id = aws_apigatewayv2_api.event_api.id
  name = "default"
  auto_deploy = true
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

output "api_endpoint" { value = "${aws_apigatewayv2_api.event_api.api_endpoint}/messages" }
output "sqs_queue_url" { value = aws_sqs_queue.event_queue.url }