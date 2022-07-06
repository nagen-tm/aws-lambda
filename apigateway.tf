## resources DOCS: https://registry.terraform.io/providers/hashicorp/aws/2.43.0/docs/resources/api_gateway_account

resource "aws_api_gateway_rest_api" "root" {
  name        = "MyDemoAPI"
  description = "This is my API for demonstration purposes"
}

resource "aws_api_gateway_resource" "root" {
  rest_api_id = "${aws_api_gateway_rest_api.root.id}"
  parent_id   = "${aws_api_gateway_rest_api.root.root_resource_id}"
  path_part   = "aws-lambda-demo"
}

resource "aws_api_gateway_method" "demo_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.root.id}"
  resource_id   = "${aws_api_gateway_resource.root.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "demo_integration" {
  rest_api_id          = "${aws_api_gateway_rest_api.root.id}"
  resource_id          = "${aws_api_gateway_resource.root.id}"
  http_method          = "${aws_api_gateway_method.demo_mehthod.http_method}"
  type                 = "MOCK"
  cache_key_parameters = ["method.request.path.param"]
  cache_namespace      = "foobar"
  timeout_milliseconds = 29000

  request_parameters = {
    "integration.request.header.X-Authorization" = "'static'"
  }

  # Transforms the incoming XML request to JSON
  request_templates = {
    "application/xml" = <<EOF
{
   "body" : $input.json('$')
}
EOF
  }
}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = "${aws_api_gateway_rest_api.root.id}"
  resource_id = "${aws_api_gateway_resource.root.id}"
  http_method = "${aws_api_gateway_method.MyDemoMethod.http_method}"
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "aws-lambda-demo-response" {
  rest_api_id = "${aws_api_gateway_rest_api.MyDemoAPI.id}"
  resource_id = "${aws_api_gateway_resource.MyDemoResource.id}"
  http_method = "${aws_api_gateway_method.MyDemoMethod.http_method}"
  status_code = "${aws_api_gateway_method_response.response_200.status_code}"

  # Transforms the backend JSON response to XML
  response_templates = {
    "application/xml" = <<EOF
#set($inputRoot = $input.path('$'))
<?xml version="1.0" encoding="UTF-8"?>
<message>
    $inputRoot.body
</message>
EOF
  }
}