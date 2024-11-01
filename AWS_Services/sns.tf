resource "aws_sns_topic" "transcription_notifications" {
  name = "transcription-job-complete"
}

resource "aws_sns_topic_subscription" "sms_subscription" {
  topic_arn = aws_sns_topic.transcription_notifications.arn
  protocol  = "sms"
  endpoint  = var.phone_number
}
