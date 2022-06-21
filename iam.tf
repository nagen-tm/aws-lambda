# lambda
# ---
# lambda resource role
resource "aws_iam_role" "hello_world"{
  name = "${var.repo_name}-lambda-hello-world"

  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [{
      Action : "sts:AssumeRole",
      Principle : {
        Service : "lambda.amazonaws.com"
      },
      Effect : "Allow"
    }]
  })
}

# lambda policy for role
resource "aws_iam_role_policy" "hello_world" {
  name = "${var.repo_name}-lambda-hello-world-policy"
  role = aws_iam_role.hello_world.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Effect   = "Allow"
      Resource = "${}"
    }, {
      Action = [
        "ec2:CreateNetworkInterface",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeNetworkInterfaces"
      ]
      Effect   = "Allow"
      Resource = "*"
    },    
    ]
  })
}