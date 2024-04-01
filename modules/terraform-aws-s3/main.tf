locals {
    method = {
      get = "GET"
      head = "HEAD"
      put = "PUT"
    }
    header = {
        x-amz-server-side-encryption = "x-amz-server-side-encryption"
        x-amz-request-id = "x-amz-request-id"
        x-amz-id-2 = "x-amz-id-2"
    }
}

data "aws_caller_identity" "current" {}

# image
resource "aws_s3_bucket" "image_bucket" {
  bucket = "${var.env}-daedong-image-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
}

resource "aws_s3_bucket_cors_configuration" "image_bucket" {
  bucket = aws_s3_bucket.image_bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = [local.method.get, local.method.head]
    allowed_origins = ["https://${var.image_cloudfront_domain}"] # TODO
    expose_headers  = [
      local.header.x-amz-server-side-encryption,
      local.header.x-amz-request-id,
      local.header.x-amz-id-2
    ]
    max_age_seconds = 3000
  }

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = [local.method.put]
    allowed_origins = ["https://${var.domain}"] # TODO
    expose_headers  = [
      local.header.x-amz-server-side-encryption,
      local.header.x-amz-request-id,
      local.header.x-amz-id-2
    ]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_policy" "image_bucket" {
  bucket = aws_s3_bucket.image_bucket.id
  policy = data.aws_iam_policy_document.image_bucket_policy_data.json
}

# admin
# resource "aws_s3_bucket" "admin_bucket" {
#   bucket = "${var.env}-daedong-admin-${data.aws_caller_identity.current.account_id}"
#   force_destroy = true
# }

# resource "aws_s3_bucket_public_access_block" "admin_bucket" {
#   bucket = aws_s3_bucket.admin_bucket.id

#   block_public_acls       = false
#   block_public_policy     = false
#   ignore_public_acls      = false
#   restrict_public_buckets = false
# }

# resource "aws_s3_bucket_cors_configuration" "admin_bucket" {
#   bucket = aws_s3_bucket.admin_bucket.id

#   cors_rule {
#     allowed_headers = ["*"]
#     allowed_methods = [local.method.get, local.method.head]
#     allowed_origins = ["*"] # TODO
#     expose_headers  = []
#     max_age_seconds = 3000
#   }
# }

# resource "aws_s3_bucket_policy" "admin_bucket" {
#   bucket = aws_s3_bucket.admin_bucket.id
#   policy = data.aws_iam_policy_document.admin_bucket_policy_data.json
# }

# resource "aws_s3_bucket_website_configuration" "admin_bucket" {
#   bucket = aws_s3_bucket.admin_bucket.id

#   index_document {
#     suffix = "index.html"
#   }

#   error_document {
#     key = "index.html"
#   }
# }

# # CodePipeline
# resource "aws_s3_bucket" "admin_codepipeline_bucket" {
#   bucket = "${var.env}-daedong-admin-codepipeline-${data.aws_caller_identity.current.account_id}"
#   force_destroy = true
# }

# resource "aws_s3_bucket_policy" "admin_codepipeline_bucket" {
#   bucket = aws_s3_bucket.admin_codepipeline_bucket.id
#   policy = data.aws_iam_policy_document.admin_codepipeline_bucket_policy_data.json
# }
