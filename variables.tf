variable "repo_name" {
  description = "Name of repo"
  type = string
  default = "aws-lambda"
}

variable "aws_region" {
  description = "AWS deployment redion"
  type = string
  default = "us-east-2"
}

variable "lambda_runtime" {
  description = "Runtime env for Lambda functions"
  type = string
  default = "go1.x"
}

variable "lambda_memory" {
  description = "lambda memory in 1MB incrememts"
  type = number
  default = 128
}

variable "lambda_timeout" {
  description = "lambda timeout in seconds"
  type = number
  default = 900
}
