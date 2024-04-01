locals {
    github = {
        branch = "${var.env}" == "stage" ? "dev" : "main"
        admin_repository = "${var.github_organization}/bread-map-admin-web"
    }
    api_domain = format("%s.%s", "api", "${var.domain}")
}

resource "aws_codebuild_project" "admin_codebuild" {
    name               = "${var.env}-daedong-admin-codebuild"

    environment {
        type                        = "LINUX_CONTAINER"
        image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"

        compute_type = "BUILD_GENERAL1_SMALL"

        environment_variable {
            name  = "ENV"
            type  = "PLAINTEXT"
            value = "dev"
        }

        environment_variable {
            name  = "VITE_API_URI"
            type  = "PLAINTEXT"
            value = "https://${local.api_domain}/v1" # TODO
        }

        environment_variable {
            name  = "S3_BUCKET_NAME"
            type  = "PLAINTEXT"
            value = "${var.admin_bucket_name}"
        }

        environment_variable {
            name  = "DISTRIBUTION_ID"
            type  = "PLAINTEXT"
            value = "${var.admin_cloudfront_id}"
        }
    }

    source {
        type                = "CODEPIPELINE"
        buildspec           = "buildspec.yml"
    }

    artifacts {
        type                   = "CODEPIPELINE"
    }

    logs_config {
        cloudwatch_logs {
            status = "ENABLED"
        }
    }

    service_role       = "${var.admin_codebuild_role_arn}"
}

resource "aws_codepipeline" "admin_codepipeline" {
    name     = "${var.env}-daedong-admin-pipeline"
    role_arn = "${var.admin_codepipeline_role_arn}"

    artifact_store {
        location = "${var.admin_codepipeline_bucket}"
        type     = "S3"
    }

    stage {
        name = "Source"
        action {
            category = "Source"
            provider         = "CodeStarSourceConnection"

            region           = "ap-northeast-2"
            name             = "Source"
            configuration = {
                ConnectionArn        = aws_codestarconnections_connection.admin_github.arn
                FullRepositoryId     = local.github.admin_repository
                BranchName           = local.github.branch
                OutputArtifactFormat = "CODE_ZIP"
            }

            namespace        = "SourceVariables"
            output_artifacts = ["SourceArtifact"]

            owner            = "AWS"
            run_order        = 1
            version          = 1
        }
    }

    stage {
        name = "Build"
        action {
            category = "Build"
            provider         = "CodeBuild"

            region           = "ap-northeast-2"
            name             = "Build"
            input_artifacts  = ["SourceArtifact"]
            configuration = {
                ProjectName = aws_codebuild_project.admin_codebuild.name
            }

            namespace        = "BuildVariables"
            output_artifacts = ["BuildArtifact"]

            owner            = "AWS"
            run_order        = 1
            version          = 1
        }
    }
}

resource "aws_codestarconnections_connection" "admin_github" {
    name          = "${var.env}-daedong-admin-github"
    provider_type = "GitHub"
}
