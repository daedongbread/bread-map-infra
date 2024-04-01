variable "env" {
    type = string
}
# variable "feedback_role_arn" {
#     type = string
# }
# variable "ip_update_to_slack_role_arn" {
#     type = string
# }
variable "image_resizer_role_arn" {
    type = string
}
variable "api_log_group_arn" {
    type = string
}
variable "api_log_group_name" {
    type = string
}
# variable "api_cloudwatch_to_slack_role_arn" {
#     type = string
# }
variable "rds_slowquery_log_group_arn" {
    type = string
}
variable "rds_slowquery_log_group_name" {
    type = string
}
# variable "rds_slowquery_to_slack_role_arn" {
#     type = string
# }
