data "aws_caller_identity" "current" {}

# Terraform Backend
resource "aws_s3_bucket" "tfstate" {
  bucket = "${var.env}-daedong-terraform-remote-state-${data.aws_caller_identity.current.account_id}"

  force_destroy = true
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "tfstate_versioning" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name         = "${var.env}-daedong-terraform-state-lock-${data.aws_caller_identity.current.account_id}"
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"
  deletion_protection_enabled = true

  attribute {
    name = "LockID"
    type = "S"
  }
}

# IAM
## GitHub Actions
data "aws_iam_openid_connect_provider" "github_actions" {
  url = "https://token.actions.githubusercontent.com"
}

data "aws_iam_policy_document" "github_actions_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_organization}/*:*"] # TODO
    }

    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github_actions.arn]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name               = "${var.env}-GithubActionsRole"
  assume_role_policy = data.aws_iam_policy_document.github_actions_policy.json
}

resource "aws_iam_role_policy_attachment" "github_actions_full_access" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess" # TODO
}

# Lambda
data "aws_iam_policy_document" "lambda_trust_policy" {
  statement {
    actions    = ["sts:AssumeRole"]
    effect     = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "api_cloudwatch_to_slack" {
  name               = "${var.env}-ApiCloudwatchToSlackRole"
  assume_role_policy = data.aws_iam_policy_document.lambda_trust_policy.json
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]
}

resource "aws_iam_role" "ip_update_to_slack" {
  name               = "${var.env}-IpUpdateToSlackRole"
  assume_role_policy = data.aws_iam_policy_document.lambda_trust_policy.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess",
  ]
}

resource "aws_iam_role" "rds_slowquery_to_slack" {
  name               = "${var.env}-RdsSlowqueryToSlackRole"
  assume_role_policy = data.aws_iam_policy_document.lambda_trust_policy.json
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]
}

resource "aws_iam_role" "image_resizer" {
  name               = "${var.env}-ImageResizerRole"
  assume_role_policy = data.aws_iam_policy_document.lambda_edge_trust_policy.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess",
    aws_iam_policy.image_resizer.arn
  ]
}

data "aws_iam_policy_document" "lambda_edge_trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = [
        "lambda.amazonaws.com",
        "edgelambda.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_policy" "image_resizer" {
  name   = "${var.env}-ResizeLambdaPolicy"
  policy = data.aws_iam_policy_document.image_resize.json
}

data "aws_iam_policy_document" "image_resize" {
  statement {
    effect = "Allow"

    actions = [
        "iam:CreateServiceLinkedRole",
        "lambda:GetFunction",
        "lambda:EnableReplication",
        "cloudfront:UpdateDistribution",
        "s3:GetObject",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams"
    ]
    resources = ["*"]
  }
}

# resource "aws_iam_role_policy_attachment" "github_actions_ecs_full_access" {
#   role       = aws_iam_role.github_actions.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
# }

# resource "aws_iam_role_policy_attachment" "github_actions_ec2_container_registry_full_access" {
#   role       = aws_iam_role.github_actions.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
# }

# resource "aws_iam_role_policy_attachment" "github_actions_terraform_state_s3_access" {
#   role       = aws_iam_role.github_actions.name
#   policy_arn = aws_iam_policy.terraform_state_s3_access_policy.arn
# }

# resource "aws_iam_policy" "terraform_state_s3_access_policy" {
#   name        = "${var.env}-TerraformStateS3AccessPolicy"
#   policy = data.aws_iam_policy_document.terraform_state_s3_access.json
# }

# data "aws_iam_policy_document" "terraform_state_s3_access" {
#   statement {
#     effect = "Allow"

#     actions = [
#         "s3:ListBucket"
#     ]
#     resources = [
#       "${aws_s3_bucket.tfstate.arn}",
#     ]
#   }

#   statement {
#     effect = "Allow"

#     actions = [
#         "s3:GetObject",
#         "s3:PutObject"
#     ]
#     resources = [
#       "${aws_s3_bucket.tfstate.arn}/*" # TODO
#     ]
#   }
# }

# resource "aws_iam_role_policy_attachment" "github_actions_terraform_state_dynamodb_access" {
#   role       = aws_iam_role.github_actions.name
#   policy_arn = aws_iam_policy.terraform_state_dynamodb_policy.arn
# }

# resource "aws_iam_policy" "terraform_state_dynamodb_policy" {
#   name        = "${var.env}-TerraformStateDynamoDBPolicy"
#   policy = data.aws_iam_policy_document.terraform_state_dynamodb_access.json
# }

# data "aws_iam_policy_document" "terraform_state_dynamodb_access" {
#   statement {
#     effect = "Allow"

#     actions = [
#         "dynamodb:DescribeTable",
#         "dynamodb:GetItem",
#         "dynamodb:PutItem",
#         "dynamodb:DeleteItem"
#     ]
#     resources = [
#       "${aws_dynamodb_table.terraform_state_lock.arn}",
#     ]
#   }
# }

# ECR
resource "aws_ecr_repository" "api" {
  name         = "${var.env}-daedong-api"
  force_delete = true
}

resource "aws_ecr_lifecycle_policy" "api" {
  repository = aws_ecr_repository.api.name
  policy     = <<EOF
    {
        "rules": [
            {
                "description": "이미지 갯수 5개 초과 시 이미지 삭제",
                "rulePriority": 1,
                "selection": {
                    "tagStatus": "any",
                    "countType": "imageCountMoreThan",
                    "countNumber": 5
                },
                "action": {
                    "type": "expire"
                }
            }
        ]
    }
    EOF
}
