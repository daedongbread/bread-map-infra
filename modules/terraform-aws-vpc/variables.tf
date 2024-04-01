variable "env" {
    type = string
}
variable "availability_zones" {
    type = list(string)
}
variable "vpc_cidr" {
    type = string
}
variable "image_bucket_arn" {
    type = string
}
variable "ecs_task_role_arn" {
    type = string
}