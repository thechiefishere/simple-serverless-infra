provider "aws" {
  region = "us-east-1"
}

module "iam" {
  source = "./modules/iam"
  project_name = var.project_name
}

module "lambda" {
  source = "./modules/lambda"

  project_name = var.project_name 
  iam_role_arn = module.iam.iam_role_arn
}

module "api-gateway" {
  source = "./modules/api-gateway"

  project_name = var.project_name 
  lambda_arn = module.lambda.lambda_function_arn
}