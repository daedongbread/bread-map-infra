output "api_cloudwatch_to_slack_role_arn" {
    value = data.aws_iam_role.api_cloudwatch_to_slack.arn
}
output "ip_update_to_slack_role_arn" {
    value = data.aws_iam_role.ip_update_to_slack.arn
}
output "rds_slowquery_to_slack_role_arn" {
    value = data.aws_iam_role.rds_slowquery_to_slack.arn
}
output "image_resizer_role_arn" {
    value = data.aws_iam_role.image_resizer.arn
}
output "ecs_event_role_arn" {
    value = aws_iam_role.ecs_event.arn
}
output "ecs_task_role_arn" {
    value = aws_iam_role.ecs_task_role.arn
}
output "ecs_task_execution_role_arn" {
    value = aws_iam_role.ecs_task_execution_role.arn
}
output "ecs_instance_profile_arn" {
    value = aws_iam_instance_profile.ecs_instance_profile.arn
}
# output "admin_codebuild_role_arn" {
#     value = aws_iam_role.admin_codebuild.arn
# }
# output "admin_codepipeline_role_arn" {
#     value = aws_iam_role.admin_codepipeline.arn
# }

