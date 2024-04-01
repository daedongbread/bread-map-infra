terraform {
    required_providers {
        aws = {
            source                = "hashicorp/aws"
            version               = "~> 4.0"
            configuration_aliases = [ aws.virginia ]
        }
    }
}

# api cloudwatch to slack
data "aws_lambda_function" "api_cloudwatch_to_slack" {
    function_name                  = "${var.env}-api-cloudwatch-to-slack"
}

resource "aws_cloudwatch_log_subscription_filter" "cloudwatch_log_ecs_api" {
    destination_arn = data.aws_lambda_function.api_cloudwatch_to_slack.arn
    log_group_name  = var.api_log_group_name
    name            = "exception_with_out_404"
    filter_pattern  = "ERROR -\"No handler found for\" -\"만료된 토큰입니다.\" -\"잘못된 Jwt 서명입니다\" -\"error field\""
}

resource "aws_lambda_permission" "api_cloudwatch_to_slack_permission" {
    action        = "lambda:InvokeFunction"
    function_name = data.aws_lambda_function.api_cloudwatch_to_slack.function_name
    principal     = "logs.amazonaws.com"
}

# ip update to slack
data "aws_lambda_function" "ip_update_to_slack" {
    function_name                  = "${var.env}-ip-update-to-slack"
}

# rds slowquery to slack
data "aws_lambda_function" "rds_slowquery_to_slack" {
    function_name                  = "${var.env}-rds-slowquery-to-slack"
}

resource "aws_cloudwatch_log_subscription_filter" "rds_slowquery" {
    destination_arn = data.aws_lambda_function.rds_slowquery_to_slack.arn
    log_group_name  = var.rds_slowquery_log_group_name
    name            = "slowquery_without_rdsadmin"
    filter_pattern  = "-\"rdsadmin\""
}

resource "aws_lambda_permission" "rds_slowquery_to_slack_permission" {
    action        = "lambda:InvokeFunction"
    function_name = data.aws_lambda_function.rds_slowquery_to_slack.function_name
    principal     = "logs.amazonaws.com"
}

# image resizer
data "aws_lambda_function" "image_resizer" {
    provider = aws.virginia
    function_name                  = "${var.env}-image-resizer"
}
