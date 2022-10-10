resource "aws_lambda_function" "screenserver" {
  function_name = "screenserver"

  s3_bucket = aws_s3_bucket.screenserver.id
  s3_key    = aws_s3_object.screenserver.key

  runtime = "python3.9"
  handler = "screenserver.lambda_handler"

  source_code_hash = data.archive_file.screenserver.output_base64sha256

  role = aws_iam_role.screenserver.arn

  environment {
    variables = {
      LOG_LEVEL = "debug"
      S3_BUCKET = var.target_bucket
      BASE_URL  = var.base_url
      TOKEN     = random_password.upload_secret.result
    }
  }

}

resource "aws_cloudwatch_log_group" "screenserver" {
  name = "/aws/lambda/${aws_lambda_function.screenserver.function_name}"

  retention_in_days = 30
}

resource "aws_iam_role" "screenserver" {
  name = "screenserver-lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.screenserver.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_policy" {
  name_prefix = "screenserver-lambda"
  role = aws_iam_role.screenserver.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:PutObject",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::${var.target_bucket}/${var.target_bucket_subpath}*"
      },
    ]
  })
}

resource "random_password" "upload_secret" {
  length           = 32
  special          = false
}