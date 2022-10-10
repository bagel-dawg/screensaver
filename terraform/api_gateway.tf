resource "aws_api_gateway_rest_api" "screenserver" {
  name        = "screenserver ${var.environment} API"
   // Wildcard mimes, accept any
  binary_media_types = ["application/octet-stream"]
}

resource "aws_api_gateway_resource" "screenserver" {
  parent_id   = aws_api_gateway_rest_api.screenserver.root_resource_id
  path_part   = "upload"
  rest_api_id = aws_api_gateway_rest_api.screenserver.id
}

resource "aws_api_gateway_method" "screenserver" {
  authorization = "NONE"
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.screenserver.id
  rest_api_id   = aws_api_gateway_rest_api.screenserver.id
}

resource "aws_api_gateway_integration" "screenserver" {
  http_method = aws_api_gateway_method.screenserver.http_method
  resource_id = aws_api_gateway_resource.screenserver.id
  rest_api_id = aws_api_gateway_rest_api.screenserver.id
  type   = "AWS_PROXY"
  uri                         = aws_lambda_function.screenserver.invoke_arn
  integration_http_method     = "POST"
}

resource "aws_api_gateway_deployment" "screenserver" {
  rest_api_id = aws_api_gateway_rest_api.screenserver.id

  triggers = {
    # NOTE: The configuration below will satisfy ordering considerations,
    #       but not pick up all future REST API changes. More advanced patterns
    #       are possible, such as using the filesha1() function against the
    #       Terraform configuration file(s) or removing the .id references to
    #       calculate a hash against whole resources. Be aware that using whole
    #       resources will show a difference after the initial implementation.
    #       It will stabilize to only change when resources change afterwards.
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.screenserver.id,
      aws_api_gateway_method.screenserver.id,
      aws_api_gateway_integration.screenserver.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "screenserver" {
  deployment_id = aws_api_gateway_deployment.screenserver.id
  rest_api_id   = aws_api_gateway_rest_api.screenserver.id
  stage_name    = var.environment
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.screenserver.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.screenserver.execution_arn}/*/*"
}
