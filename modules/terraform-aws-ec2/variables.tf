variable "env" {
    type = string
}
variable "instance_type" {
    type = string
}
variable "ecs_security_group_id" {
    type = string
}
variable "ecs_instance_profile_arn" {
    type = string
}
variable "ecs_cluster_name" {
    type = string
}
variable "svc_pub_subnet_ids" {
    type = list(string)
}
variable "min_size" {
    type = number
}
variable "max_size" {
    type = number
}
variable "desired_capacity" {
    type = number
}
variable "key_pair_name" {
    type = string
}
