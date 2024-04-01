output "image_resizer_arn" {
    value = data.aws_lambda_function.image_resizer.arn
}
output "ip_update_to_slack_arn" {
    value = data.aws_lambda_function.ip_update_to_slack.arn
}
output "api_cloudwatch_to_slack_name" {
    value = data.aws_lambda_function.api_cloudwatch_to_slack.function_name
}
output "ip_update_to_slack_name" {
    value = data.aws_lambda_function.ip_update_to_slack.function_name
}
output "rds_slowquery_to_slack_name" {
    value = data.aws_lambda_function.rds_slowquery_to_slack.function_name
}
output "image_resizer_name" {
    value = data.aws_lambda_function.image_resizer.function_name
}
output "image_resizer_qualified_arn" {
    value = data.aws_lambda_function.image_resizer.qualified_arn
}
