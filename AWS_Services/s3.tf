# Get existing bucket
data "aws_s3_bucket" "project_diane_bucket" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = data.aws_s3_bucket.project_diane_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.audio_transcribe_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "source/"
    filter_suffix       = ".wav"
  }
  depends_on = [aws_lambda_permission.allow_bucket]
}

