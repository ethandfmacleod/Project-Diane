resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda-transcription-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "lambda_basic_execution" {
  name       = "lambda-attachment"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  roles      = [aws_iam_role.lambda_execution_role.name]
}

resource "aws_iam_role_policy_attachment" "lambda_s3_full_access" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_transcribe_full_access" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonTranscribeFullAccess"
}

resource "aws_lambda_function" "audio_transcribe_lambda" {
  filename      = "${path.module}/../Lambda/Lambda.zip"
  function_name = "transcribe_audio_function"
  handler       = "transcribe_function.handler"
  runtime       = "python3.8"
  role          = aws_iam_role.lambda_execution_role.arn
  environment {
    variables = {
      S3_BUCKET_NAME = data.aws_s3_bucket.project_diane_bucket.bucket
      SNS_TOPIC_ARN  = aws_sns_topic.transcription_notifications.arn
    }
  }
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.audio_transcribe_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = data.aws_s3_bucket.project_diane_bucket.arn
}