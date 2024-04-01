variable "env" {
    type = string
}
variable "github_organization" {
    type = string
}
variable "availability_zones" {
    type = list(string)
}
variable "vpc_cidr" {
    type = string
}
variable "domain" {
    type = string
}
variable "rds_password" {
    type = string
    sensitive = true
}
variable "instance_type" {
    type = string
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
variable "api_image_tag" {
    type = string
}
variable "api_cpu" {
    type = number
}
variable "api_memory" {
    type = number
}
variable "search_master_user_name" {
    type = string
}
variable "search_master_user_password" {
    type = string
}
variable "sgis_key" {
    type = string
}
variable "sgis_secret" {
    type = string
}
variable "jwt_key" {
    type = string
}
variable "jwt_admin_key" {
    type = string
}
variable "firebase_projectid" {
    type = string
}
variable "firebase_credentials" {
    type = string
}
