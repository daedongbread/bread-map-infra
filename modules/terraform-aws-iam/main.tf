# ecs
data "aws_iam_policy_document" "ecs_task_trust_policy" {
  statement {
    actions    = ["sts:AssumeRole"]
    effect     = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_role" {
  name = "ecsTaskRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_trust_policy.json
  managed_policy_arns = [
    aws_iam_policy.s3_access_policy.arn,
    "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
  ]
}

resource "aws_iam_policy" "s3_access_policy" {
  name        = "${var.env}-S3AccessPolicy"
  policy = data.aws_iam_policy_document.s3_access.json
}

data "aws_iam_policy_document" "s3_access" {
  statement {
    effect = "Allow"

    actions = [
        "s3:PutObject",
        "s3:ListBucket"
    ]
    resources = [
      "${var.image_bucket_arn}",
      "${var.image_bucket_arn}/*"
    ]
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_trust_policy.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
  ]
}

data "aws_iam_policy_document" "ec2_trust_policy" {
  statement {
    actions    = ["sts:AssumeRole"]
    effect     = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_instance_role" {
  name = "ecsInstanceRole"
  assume_role_policy = data.aws_iam_policy_document.ec2_trust_policy.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  ]
}
resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecsInstanceProfile"
  role = aws_iam_role.ecs_instance_role.name
}

# ecs eventbridge
resource "aws_iam_role" "ecs_event" {
  name               = "ecsEventsRole"
  assume_role_policy = data.aws_iam_policy_document.event_trust_policy.json
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceEventsRole"]
}

data "aws_iam_policy_document" "event_trust_policy" {
  statement {
    actions    = ["sts:AssumeRole"]
    effect     = "Allow"
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

# Lambda
data "aws_iam_role" "api_cloudwatch_to_slack" {
    name               = "${var.env}-ApiCloudwatchToSlackRole"
}

data "aws_iam_role" "ip_update_to_slack" {
    name               = "${var.env}-IpUpdateToSlackRole"
}

data "aws_iam_role" "rds_slowquery_to_slack" {
    name               = "${var.env}-RdsSlowqueryToSlackRole"
}

data "aws_iam_role" "image_resizer" {
    name               = "${var.env}-ImageResizerRole"
}

# github actions
data "aws_iam_role" "github_actions" {
  name               = "${var.env}-GithubActionsRole"
}

resource "aws_iam_role_policy_attachment" "github_actions" {
  role = data.aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.update_image_resize_lambda.arn
}

resource "aws_iam_policy" "update_image_resize_lambda" {
  name   = "${var.env}-UpdateImageResizeLambdaPolicy"
  policy = data.aws_iam_policy_document.update_image_resize_lambda.json
}

data "aws_iam_policy_document" "update_image_resize_lambda" {
  statement {
    effect = "Allow"

    actions = [
        "lambda:UpdateFunctionCode"
    ]
    resources = ["${var.image_resizer_lambda_arn}"]
  }
}

# data "aws_iam_openid_connect_provider" "github_actions" {
#   url = "https://token.actions.githubusercontent.com"
# }

# resource "aws_iam_openid_connect_provider" "github_actions" {
#   url = "https://token.actions.githubusercontent.com"

#   client_id_list = [
#     "sts.amazonaws.com",
#   ]

#   thumbprint_list = [""] # https://github.com/hashicorp/terraform-provider-aws/issues/32480
# }

# opensearch
resource "aws_cloudwatch_log_resource_policy" "opensearch_log_policy" {
  policy_name     = "OpenSearchService-${var.opensearch_search_domain_name}-logs"
  policy_document = data.aws_iam_policy_document.opensearch_log_policy.json
}

data "aws_iam_policy_document" "opensearch_log_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["es.amazonaws.com"]
    }

    actions = [
      "logs:PutLogEvents",
      "logs:PutLogEventsBatch",
      "logs:CreateLogStream"
    ]

    resources = ["arn:aws:logs:*"] # TODO
  }
}

# codeseries
# data "aws_iam_policy_document" "codebuild_policy" {
#   statement {
#     actions    = ["sts:AssumeRole"]
#     effect     = "Allow"
#     principals {
#       type        = "Service"
#       identifiers = ["codebuild.amazonaws.com"]
#     }
#   }
# }

# resource "aws_iam_role" "admin_codebuild" {
#   name               = "${var.env}-AdminCodeBuildServiceRole"
#   assume_role_policy = data.aws_iam_policy_document.codebuild_policy.json
#   managed_policy_arns = [
#     "arn:aws:iam::aws:policy/service-role/AmazonS3FullAccess",
#     "arn:aws:iam::aws:policy/service-role/CloudFrontFullAccess"
#   ]
# }

# resource "aws_iam_role_policy_attachment" "admin_codebuild" {
#   role = data.aws_iam_role.admin_codebuild.name
#   policy_arn = aws_iam_policy.admin_codebuild.arn
# }

# resource "aws_iam_policy" "admin_codebuild" {
#   name   = "${var.env}-AdminCodeBuildPolicy"
#   policy = data.aws_iam_policy_document.admin_codebuild.json
# }

# data "aws_caller_identity" "current" {}

# data "aws_iam_policy_document" "admin_codebuild" {
#   statement {
#     effect    = "Allow"
#     actions   = [
#       "logs:CreateLogGroup",
#       "logs:CreateLogStream",
#       "logs:PutLogEvents"
#     ]
#     resources = [
#       # "arn:aws:logs:ap-northeast-2:571281437321:log-group:/aws/codebuild/stage-bread-map-admin-codebuild",
#       # "arn:aws:logs:ap-northeast-2:571281437321:log-group:/aws/codebuild/stage-bread-map-admin-codebuild:*"
#       "${var.admin_codebuild_log_group_arn}",
#       "${var.admin_codebuild_log_group_arn}:*"
#     ]
#   }

#   statement {
#     effect    = "Allow"
#     actions   = [
#       "s3:PutObject",
#       "s3:GetObject",
#       "s3:GetObjectVersion",
#       "s3:GetBucketAcl",
#       "s3:GetBucketLocation"
#     ]
#     resources = [
#       "arn:aws:s3:::codepipeline-ap-northeast-2-*"
#     ]
#   }

#   statement {
#     effect    = "Allow"
#     actions   = [
#       "codebuild:CreateReportGroup",
#       "codebuild:CreateReport",
#       "codebuild:UpdateReport",
#       "codebuild:BatchPutTestCases",
#       "codebuild:BatchPutCodeCoverages"
#     ]
#     resources = [ # TODO
#       "arn:aws:codebuild:ap-northeast-2:${data.aws_caller_identity.current.account_id}:report-group/${var.admin_codebuild_name}-*"
#     ]
#   }
# }

# data "aws_iam_policy_document" "codepipeline_policy" {
#   statement {
#     actions    = ["sts:AssumeRole"]
#     effect     = "Allow"
#     principals {
#       type        = "Service"
#       identifiers = ["codepipeline.amazonaws.com"]
#     }
#   }
# }

# resource "aws_iam_role" "admin_codepipeline" {
#   name               = "${var.env}-AdminCodePipelineServiceRole"
#   assume_role_policy = data.aws_iam_policy_document.codepipeline_policy.json
#   managed_policy_arns = [
#     "arn:aws:iam::aws:policy/service-role/AmazonS3FullAccess",
#     "arn:aws:iam::aws:policy/service-role/CloudFrontFullAccess"
#   ]
# }

# resource "aws_iam_role_policy_attachment" "admin_codepipeline" {
#   role = data.aws_iam_role.admin_codepipeline.name
#   policy_arn = aws_iam_policy.admin_codepipeline.arn
# }

# resource "aws_iam_policy" "admin_codepipeline" {
#   name   = "${var.env}-AdminCodePipelinePolicy"
#   policy = data.aws_iam_policy_document.admin_codepipeline.json
# }

# data "aws_iam_policy_document" "admin_codepipeline" {
#   statement {
#     effect    = "Allow"
#     actions   = ["iam:PassRole"]
#     resources = ["*"]
#     condition {
#       test     = "StringEqualsIfExists"
#       variable = "iam:PassedToService"
#       values   = [
#         "cloudformation.amazonaws.com",
#         "elasticbeanstalk.amazonaws.com",
#         "ec2.amazonaws.com",
#         "ecs-tasks.amazonaws.com"
#       ]
#     }
#   }

#   statement {
#     effect    = "Allow"
#     actions   = [
#       "codecommit:CancelUploadArchive",
#       "codecommit:GetBranch",
#       "codecommit:GetCommit",
#       "codecommit:GetRepository",
#       "codecommit:GetUploadArchiveStatus",
#       "codecommit:UploadArchive"
#     ]
#     resources = ["*"]
#   }

#   statement {
#     effect    = "Allow"
#     actions   = [
#       "codedeploy:CreateDeployment",
#       "codedeploy:GetApplication",
#       "codedeploy:GetApplicationRevision",
#       "codedeploy:GetDeployment",
#       "codedeploy:GetDeploymentConfig",
#       "codedeploy:RegisterApplicationRevision"
#     ]
#     resources = ["*"]
#   }

#   statement {
#     effect    = "Allow"
#     actions   = ["codestar-connections:UseConnection"]
#     resources = ["*"]
#   }

#   statement {
#     effect    = "Allow"
#     actions   = [
#       "elasticbeanstalk:*",
#       "ec2:*",
#       "elasticloadbalancing:*",
#       "autoscaling:*",
#       "cloudwatch:*",
#       "s3:*",
#       "sns:*",
#       "cloudformation:*",
#       "rds:*",
#       "sqs:*",
#       "ecs:*"
#     ]
#     resources = ["*"]
#   }

#   statement {
#     effect    = "Allow"
#     actions   = [
#       "lambda:InvokeFunction",
#       "lambda:ListFunctions"
#     ]
#     resources = ["*"]
#   }

#   statement {
#     effect    = "Allow"
#     actions   = [
#       "opsworks:CreateDeployment",
#       "opsworks:DescribeApps",
#       "opsworks:DescribeCommands",
#       "opsworks:DescribeDeployments",
#       "opsworks:DescribeInstances",
#       "opsworks:DescribeStacks",
#       "opsworks:UpdateApp",
#       "opsworks:UpdateStack"
#     ]
#     resources = ["*"]
#   }

#   statement {
#     effect    = "Allow"
#     actions   = [
#       "cloudformation:CreateStack",
#       "cloudformation:DeleteStack",
#       "cloudformation:DescribeStacks",
#       "cloudformation:UpdateStack",
#       "cloudformation:CreateChangeSet",
#       "cloudformation:DeleteChangeSet",
#       "cloudformation:DescribeChangeSet",
#       "cloudformation:ExecuteChangeSet",
#       "cloudformation:SetStackPolicy",
#       "cloudformation:ValidateTemplate"
#     ]
#     resources = ["*"]
#   }

#   statement {
#     effect    = "Allow"
#     actions   = [
#       "codebuild:BatchGetBuilds",
#       "codebuild:StartBuild",
#       "codebuild:BatchGetBuildBatches",
#       "codebuild:StartBuildBatch"
#     ]
#     resources = ["*"]
#   }

#   statement {
#     effect    = "Allow"
#     actions   = [
#       "devicefarm:ListProjects",
#       "devicefarm:ListDevicePools",
#       "devicefarm:GetRun",
#       "devicefarm:GetUpload",
#       "devicefarm:CreateUpload",
#       "devicefarm:ScheduleRun"
#     ]
#     resources = ["*"]
#   }

#   statement {
#     effect    = "Allow"
#     actions   = [
#       "servicecatalog:ListProvisioningArtifacts",
#       "servicecatalog:CreateProvisioningArtifact",
#       "servicecatalog:DescribeProvisioningArtifact",
#       "servicecatalog:DeleteProvisioningArtifact",
#       "servicecatalog:UpdateProduct"
#     ]
#     resources = ["*"]
#   }

#   statement {
#     effect    = "Allow"
#     actions   = ["cloudformation:ValidateTemplate"]
#     resources = ["*"]
#   }

#   statement {
#     effect    = "Allow"
#     actions   = ["ecr:DescribeImages"]
#     resources = ["*"]
#   }

#   statement {
#     effect    = "Allow"
#     actions   = [
#       "states:DescribeExecution",
#       "states:DescribeStateMachine",
#       "states:StartExecution"
#     ]
#     resources = ["*"]
#   }

#   statement {
#     effect    = "Allow"
#     actions   = [
#       "appconfig:StartDeployment",
#       "appconfig:StopDeployment",
#       "appconfig:GetDeployment"
#     ]
#     resources = ["*"]
#   }
# }
