output "rds_slowquery_log_group_name" {
    value = aws_cloudwatch_log_group.rds_slowquery_log_group.name
}
output "rds_slowquery_log_group_arn" {
    value = aws_cloudwatch_log_group.rds_slowquery_log_group.arn
}
output "api_log_group_name" {
    value = aws_cloudwatch_log_group.ecs_api_log_group.name
}
output "api_log_group_arn" {
    value = aws_cloudwatch_log_group.ecs_api_log_group.arn
}
# output "admin_codebuild_log_group_arn" {
#     value = aws_cloudwatch_log_group.admin_codebuild_log_group.arn
# }
output "opensearch_search_log_group_arn" {
    value = aws_cloudwatch_log_group.opensearch_search.arn
}
