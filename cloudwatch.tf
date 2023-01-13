# resources
# ---
# lambda logs
resource "aws_cloudwatch_log_group" "lambda_hello_world" {
  name = "aws/lambda/${var.repo_name}-hello-world"
  retention_in_days = 14
}