resource "aws_api_gateway_integration" "proxy_integration" {
  count = "${var.aws_proxy ? 1 : 0}"
  rest_api_id             = "${var.rest_api_id}"
  resource_id             = "${aws_api_gateway_resource.resource.id}"
  http_method             = "${aws_api_gateway_method.method.http_method}"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.lambda_function_arn}/invocations"
}

resource "aws_api_gateway_integration" "integration" {
  count = "${var.aws_proxy ? 0 : 1}"
  rest_api_id             = "${var.rest_api_id}"
  resource_id             = "${aws_api_gateway_resource.resource.id}"
  http_method             = "${aws_api_gateway_method.method.http_method}"
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.lambda_function_arn}/invocations"
  passthrough_behavior    = "WHEN_NO_TEMPLATES"

  request_templates = {
    "application/json" = "${file("api_gateway_integration_module/api_gateway_integration_module/api_gateway_body_mapping.template")}"
  }
}

resource "aws_api_gateway_method" "method" {
  rest_api_id   = "${var.rest_api_id}"
  resource_id   = "${aws_api_gateway_resource.resource.id}"
  http_method   = "${var.method_type}"
  authorization = "NONE"

  depends_on = ["aws_api_gateway_resource.resource"]
}

resource "aws_api_gateway_resource" "resource" {
  path_part   = "${var.path_url}"
  parent_id   = "${var.root_resource_id}"
  rest_api_id = "${var.rest_api_id}"
}
