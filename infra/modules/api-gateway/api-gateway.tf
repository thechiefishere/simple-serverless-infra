resource "aws_api_gateway_rest_api" "backend_api" {
  name        = "${var.project_name}-api"
  description = "API for backend App"
}

resource "aws_api_gateway_resource" "api_resource" {
  rest_api_id = aws_api_gateway_rest_api.backend_api.id
  parent_id   = aws_api_gateway_rest_api.backend_api.root_resource_id
  path_part   = "api"
}

resource "aws_api_gateway_resource" "emmanuel_resource" {
  rest_api_id = aws_api_gateway_rest_api.backend_api.id
  parent_id   = aws_api_gateway_resource.api_resource.id
  path_part   = "emmanuel"
}

resource "aws_api_gateway_method" "emmanuel_resource_method" {
  rest_api_id   = aws_api_gateway_rest_api.backend_api.id
  resource_id   = aws_api_gateway_resource.emmanuel_resource.id
  authorization = "NONE"
  http_method   = "GET"
}

resource "aws_lambda_permission" "api_gateway_invoke_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_arn
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.backend_api.execution_arn}/*/*"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.backend_api.id
  resource_id = aws_api_gateway_resource.emmanuel_resource.id
  http_method = aws_api_gateway_method.emmanuel_resource_method.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/${var.lambda_arn}/invocations"
}

# Deploy API Gateway
resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.backend_api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_rest_api.backend_api.id,
      aws_api_gateway_rest_api.backend_api.root_resource_id,
      aws_api_gateway_resource.api_resource.id,
      aws_api_gateway_resource.emmanuel_resource.id,
      aws_api_gateway_integration.lambda_integration.id
      # Add other resources here as they get created
    ]))
  }
}

resource "aws_api_gateway_stage" "example" {
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.backend_api.id
  stage_name    = "dev"
}
