data "archive_file" "layer_func_archiver" {
  type        = "zip"
  source_file = "${path.module}/../../../code/index.py"
  output_path = "${path.module}/../../../code/index.zip"
}

resource "aws_lambda_function" "lambda_func" {
  function_name = "${var.project_name}-app-backends"

  runtime = "python3.13"
  handler = "index.handler"

  role = var.iam_role_arn

  # Point to the directory where you are storing your Lambda code
  filename         = "${path.module}/../../../code/index.zip"
  source_code_hash = filebase64sha256("${path.module}/../../../code/index.py")

  layers = [aws_lambda_layer_version.lambda_layer.arn]

  environment {
    variables = {
      NODE_ENV = "dev"
    }
  }
}