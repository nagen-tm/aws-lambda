# resources
# ---

resource "aws_api_gateway_rest_api" "root" {
  name = var.repo_name
  description = "Lambda Demo"
  endpoint_configuration {
    types = ["PRIVATE"]
    vpc_endpoint_ids = [var.vpc_id]
  }
}

resource "aws_api_gateway_rest_api_policy" "root" {
  rest_api_id = aws_api_gateway_rest_api.root.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{ 
      "Effect" : "Allow",
      "Principle" : "*",
      "Action" : "execution_arn:Invoke",
      "Resource" : "${aws_api_gateway_rest_api.root.execution_arn}/*/*/*"
    }]
  })
}

resource "aws_api_gateway_method_settings" "all" {
  rest_api_id = aws_api_gateway_rest_api.root.id
  stage_name = aws_api_gateway_stage.root.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = true
    logging_level = "ERROR"
  }
}

 # configure endpoints: simple hello world endpoint for the lambda 
 resource "aws_api_gateway_resource" "hello_world" {
  parent_id = aws_api_gateway_rest_api.root.root_resource_id
  path_part = "helloWorld"
  rest_api_id - aws_api_gateway_rest_api.root.id 
 }

 resource "aws_api_gateway_method" "hello_world_options" {
  authorization = "NONE"
  http_method = "OPTIONS"
  resource_id = aws_api_gateway_resource.hello_world.id
  rest_api_id = aws_api_gateway_rest_api.root.id
 }

 resource "aws_api_gateway_integration" "hello_world_options" {
  http_method = aws_api_gateway_method.hello_world_options.http_method
  resource_id = aws_api_gateway_resource.hello_world.id
  rest_api_id = aws_api_gateway_rest_api.root.id
  type = "MOCK"

  response_models = {
    "application/json" = "{\"statusCode\": 200}"
  }
 }

 resource "aws_api_gateway_integration" "hello_world_options_200" {
  http_method = aws_api_gateway_method.hello_world_options.http_method
  resource_id = aws_api_gateway_resource.hello_world.id
  rest_api_id = aws_api_gateway_rest_api.root.id
  status_code = 200
  response_models = {
    "application/json" = "empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Methods" = true
  }
 }

resource "aws_api_gateway_integration_response" "hello_world_options_200" {
  http_method = aws_api_gateway_method.hello_world_options.http_method
  resource_id = aws_api_gateway_resource.hello_world.id
  rest_api_id = aws_api_gateway_rest_api.root.id
  status_code = aws_api_gateway_method_response.hello_world_options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization,X-Amz-Date,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,POST'",
    "method.response.header.Access-Control-Allow-Methods" = "'*'"
  }
    
  response_templates = {
    "application/json" = ""
  }

  depends_on [
    aws_api_gateway_integration.hello_world_options
  ]
}

resource "aws_api_gateway_method" "hello_world_post" {
  authorization = "NONE"
  http_method = "OPTIONS"
  resource_id = aws_api_gateway_resource.hello_world.id
  rest_api_id = aws_api_gateway_rest_api.root.id

  request_models = {
    "application/json" = aws_api_gateway_model.hello_world_post.name
  }
}

resource "aws_api_gateway_model" "hello_world_post" {
  rest_api_id = aws_api_gateway_rest_api.root.id
  name = "POSTHelloWorldModel"
  description = ""
  content_type = "application/json"
  schema = file()
}

resource "aws_api_gateway_request_validator" "hello_world_post" {
  name = "POSTHelloWorldValidator"
  rest_api_id = aws_api_gateway_rest_api.root.id
  validate_request_body = true
}

resource "aws_api_gateway_integration" "hello_world_post" {
  http_method = aws_api_gateway_method.hello_world_post.http_method
  resource_id = aws_api_gateway_resource.hello_world.id
  rest_api_id = aws_api_gateway_rest_api.root.id
  type = "AWS"
  integration_http_method = "POST"
  uri = ''
  credentials = aws_iam_role.lambda_hello_go.execution_arn
  passthrough_behavior = "NEVER"

  response_parameters = {
    "integrastion.request.header.Content-Type" = "'application/json'"
  } 

  request_templates = {
    "application/json" = ""
  }

  depends_on = [
    aws_iam_role.lambda_hello_go
  ]
}

resource "aws_api_gateway_method_response" "hello_world_post_200" {
  http_method = aws_api_gateway_method.hello_world_post.http_method
  resource_id = aws_api_gateway_resource.hello_world.id
  rest_api_id = aws_api_gateway_rest_api.root.id
  status_code = 200
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "hello_world_post_200" {
  http_method = aws_api_gateway_method.hello_world_post.http_method
  resource_id = aws_api_gateway_resource.hello_world.id
  rest_api_id = aws_api_gateway_rest_api.root.id
  status_code = aws_api_gateway_method_response.hello_world_post_200.status_code

  request_templates = {
    "application/json" = ""
  }

  depends_on = [
    aws_api_gateway_integration.hello_world_post
  ]
}

resource "aws_api_gateway_stage" "root" {
  deployment_id = aws_api_gateway_deployment.root.id
  rest_api_id = aws_api_gateway_rest_api.root.id
  stage_name = var.env

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.lambda_hello_go.execution_arn
    format = jsconencode({
      "requestId":"$context.requestId"
      "ip":"$context.identity.sourceIP"
      "requestTime":"$context.requestTime"
      "httpMethod":"$context.httpMethod"
      "status":"$context.status"
    })
  }
}

resource "aws_api_gateway_deployment" "root" {
  rest_api_id = aws_api_gateway_rest_api.root.id
  stage_name = var.env

  depends_on = [
    aws_api_gateway_integration.hello_world_post
  ]

  triggers = {
    redeployment = sha1(jsconencode([
      aws_api_gateway_resource.hello_world,
      aws_api_gateway_method.hello_world_post,
      aws_api_gateway_integration.hello_world_post
    ]))
  }
  lifecycle {
    create_before_destroy = true
  }
}