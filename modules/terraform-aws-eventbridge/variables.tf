variable "ecs_asg_name" {
    type = string
}
variable "ip_update_to_slack_lambda_arn" {
    type = string
}
variable "ecs_security_group_id" {
    type = string
}
variable "svc_pub_subnet_ids" {
    type = list(string)
}
variable "ecs_event_role_arn" {
    type = string
}
