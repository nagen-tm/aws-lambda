# data sources 
# --- 
# data for the go function
data "archive_file" "zip_hello_world" {
  type = "zip"
  output_path = "${path.module}/dist/hello_world.zip"
  source_dir = "${path.module}/src"
  excludes = {
    # add any files needed to be exluded like unit tests
  }
}

# lambda function resource
resource "aws_lambda_function" "hello_world" {
  filename = "${path.module}/dist/hello_world.zip"
  function_name = "${var.repo_name}-hello-world"
  role = aws_iam_role.
  handler =
  source_code_hash =
  runtime = var.lambda_runtime
  timeout = var.lambda_timeout
  memory_size = var.lambda_memory

  # create any environmental variables for function
  # environment {
  #   variables = {
      
  #   }
  # }
}

# permissions to invoke the lambda
resource "aws_lambda_permission" "hello_world" {
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello_world.function_name
  principal = "apigateway.amazonaws.com"
  source_arm = "${aws_api_gateway_rest_api.root.execution_arn}/*/*/*"
}