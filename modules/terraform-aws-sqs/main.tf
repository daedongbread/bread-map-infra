data "aws_caller_identity" "current" {}

resource "aws_sqs_queue" "bakery_view_fifo" {
  fifo_queue                        = true
  name                              = "BakeryViewQueue.fifo"

  visibility_timeout_seconds        = 30
  message_retention_seconds         = 3600
  delay_seconds                     = 0
  max_message_size                  = 262144
  receive_wait_time_seconds         = 0

  content_based_deduplication       = true

  deduplication_scope               = "queue"
  fifo_throughput_limit             = "perQueue"

  sqs_managed_sse_enabled           = true
}

resource "aws_sqs_queue_policy" "bakery_view_fifo" {
  queue_url = aws_sqs_queue.bakery_view_fifo.id
  policy    = data.aws_iam_policy_document.bakery_view_fifo.json
}

data "aws_iam_policy_document" "bakery_view_fifo" {
  statement {
    actions   = ["SQS:*"]
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"] # TODO
    }
    resources = [aws_sqs_queue.bakery_view_fifo.arn]
  }
}

resource "aws_sqs_queue" "update_bakery_fifo" {
  fifo_queue                        = true
  name                              = "UpdateBakeryQueue.fifo"

  visibility_timeout_seconds        = 30
  message_retention_seconds         = 3600
  delay_seconds                     = 0
  max_message_size                  = 262144
  receive_wait_time_seconds         = 0

  content_based_deduplication       = true

  deduplication_scope               = "queue"
  fifo_throughput_limit             = "perQueue"

  sqs_managed_sse_enabled           = true
}

resource "aws_sqs_queue_policy" "update_bakery_fifo" {
  queue_url = aws_sqs_queue.update_bakery_fifo.id
  policy    = data.aws_iam_policy_document.update_bakery_fifo.json
}

data "aws_iam_policy_document" "update_bakery_fifo" {
  statement {
    actions   = ["SQS:*"]
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"] # TODO
    }
    resources = [aws_sqs_queue.update_bakery_fifo.arn]
  }
}
