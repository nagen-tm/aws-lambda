# aws-lambda
build a lambda with an API gateway using terraform and golang

## Go Lambda 
Current: just prints out Hello World 

## terraform
- IAM: create new role with permissions for API gateway and lambda
- lambda: create function and permissions to invoke
- API gateway: rest api resources and points to open API spec 
- open API spec: creates responses
- cloudwatch: create a log group for the lambda