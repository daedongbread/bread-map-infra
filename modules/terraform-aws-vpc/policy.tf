locals {
    allow = "Allow"
    action = {
        s3_get_object = "s3:GetObject"
        s3_put_object = "s3:PutObject"
        s3_list_object = "s3:ListObject"
    }
    type = {
        aws = "AWS"
    }
    condition = {
        arn_equals = "ArnEquals"
    }
}

data "aws_iam_policy_document" "s3_endpoint_policy" {
    statement {
        sid = "Access to S3 Bucket"
        effect    = local.allow
        principals {
            type        = local.type.aws
            identifiers = ["*"]
        }
        actions   = [
            local.action.s3_list_object,
            local.action.s3_put_object
        ]
        resources = [
            "${var.image_bucket_arn}",
            "${var.image_bucket_arn}/*",
        ]
        condition {
            test     = local.condition.arn_equals
            variable = "AWS:PrincipalArn"
            values   = [var.ecs_task_role_arn]
        }
    }
    statement {
        sid = "Access to ECR buckets"
        effect    = local.allow
        principals {
            type        = local.type.aws
            identifiers = ["*"]
        }
        actions   = [local.action.s3_get_object]
        resources = ["arn:aws:s3:::prod-ap-northeast-2-starport-layer-bucket/*"]
    }
}