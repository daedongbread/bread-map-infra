locals {
    effect = {
        allow = "Allow"
        deny = "Deny"
    }
    action = {
        s3_get_object = "s3:GetObject"
        s3_put_object = "s3:PutObject"
    }
    type = {
        service = "Service"
        aws = "AWS"
    }
    condition = {
        string_equals = "StringEquals"
        string_not_equals = "StringNotEquals"
        bool = "Bool"
    }
}

data "aws_iam_policy_document" "image_bucket_policy_data" {
    statement {
        sid       = "AllowCloudFrontServicePrincipal"
        effect    = local.effect.allow
        principals {
            type        = local.type.service
            identifiers = ["cloudfront.amazonaws.com"]
        }
        actions   = [local.action.s3_get_object]
        resources = ["${aws_s3_bucket.image_bucket.arn}/*"]
        condition {
            test     = local.condition.string_equals
            variable = "AWS:SourceArn"
            values   = ["${var.image_cloudfront_arn}"]
        }
    }

    statement {
        sid       = "AllowLambdaEdgeToResizeImage"
        effect    = local.effect.allow
        actions   = [local.action.s3_get_object, local.action.s3_put_object]
        resources = ["${aws_s3_bucket.image_bucket.arn}", "${aws_s3_bucket.image_bucket.arn}/*"]

        principals {
            type        = "AWS"
            identifiers = ["${var.image_resizer_role_arn}"]
        }
    }
}

# data "aws_iam_policy_document" "admin_bucket_policy_data" {
#     statement {
#         sid       = "AllowCloudFrontServicePrincipal"
#         effect    = local.effect.allow
#         principals {
#             type        = local.type.service
#             identifiers = ["cloudfront.amazonaws.com"]
#         }
#         actions   = [local.action.s3_get_object]
#         resources = ["${aws_s3_bucket.admin_bucket.arn}/*"]
#         condition {
#             test     = local.condition.string_equals
#             variable = "AWS:SourceArn"
#             values   = ["${var.admin_cloudfront_arn}"]
#         }
#     }
# }

# data "aws_iam_policy_document" "admin_codepipeline_bucket_policy_data" {
#     statement {
#         sid       = "DenyUnEncryptedObjectUploads"
#         effect    = local.effect.deny
#         principals {
#             type        = local.type.aws
#             identifiers = ["*"]
#         }
#         actions   = [local.action.s3_put_object]
#         resources = ["${aws_s3_bucket.admin_codepipeline_bucket.arn}/*"]
#         condition {
#             test     = local.condition.string_not_equals
#             variable = "s3:x-amz-server-side-encryption"
#             values   = ["aws:kms"]
#         }
#     }

#     statement {
#         sid       = "DenyInsecureConnections"
#         effect    = local.effect.deny
#         principals {
#             type        = local.type.aws
#             identifiers = ["*"]
#         }
#         actions   = ["s3:*"]
#         resources = ["${aws_s3_bucket.admin_codepipeline_bucket.arn}/*"]
#         condition {
#             test     = local.condition.bool
#             variable = "aws:SecureTransport"
#             values   = ["false"]
#         }
#     }
# }
