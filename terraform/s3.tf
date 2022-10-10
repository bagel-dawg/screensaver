data "archive_file" "screenserver" {
  type = "zip"

  source_dir  = "${path.module}/../src/screenserver"
  output_path = "${path.module}/screenserver.zip"
}

resource "aws_s3_bucket" "screenserver" {
  bucket_prefix = "screenserver-"

  tags = {
    Name        = "screenserver-src"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_acl" "screenserver" {
  bucket = aws_s3_bucket.screenserver.id
  acl    = "private"
}

resource "aws_s3_object" "screenserver" {
  bucket = aws_s3_bucket.screenserver.id

  key    = "screenserver.zip"
  source = data.archive_file.screenserver.output_path

  etag = filemd5(data.archive_file.screenserver.output_path)
}