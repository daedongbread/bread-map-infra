# lambda
resource "aws_cloudwatch_log_group" "api_cloudwatch_to_slack_log_group" {
    name              = "/aws/lambda/${var.api_cloudwatch_to_slack_lambda_name}"
}
resource "aws_cloudwatch_log_group" "ip_update_to_slack_log_group" {
    name              = "/aws/lambda/${var.ip_update_to_slack_lambda_name}"
}
resource "aws_cloudwatch_log_group" "rds_slowquery_to_slack_log_group" {
    name              = "/aws/lambda/${var.rds_slowquery_to_slack_lambda_name}"
}
resource "aws_cloudwatch_log_group" "image_resizer_log_group" {
    name = "/aws/lambda/us-east-1.${var.image_resizer_lambda_name}"
}

# rds
resource "aws_cloudwatch_log_group" "rds_slowquery_log_group" {
    name = "/aws/rds/instance/${var.rds_identifier}/slowquery"
}

# codeseries
# resource "aws_cloudwatch_log_group" "admin_codebuild_log_group" {
#     name = "/aws/codebuild/${var.env}-daedong-admin-codebuild" # TODO
# }

# ecs
resource "aws_cloudwatch_log_group" "ecs_api_log_group" {
    name = "/ecs/daedong-api" # TODo
}
