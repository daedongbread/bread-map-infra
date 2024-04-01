variable "env" {
  type = string
}
variable "api_target_group_arn" {
  type = string
}
variable "ecs_task_role_arn" {
  type = string
}
variable "ecs_task_execution_role_arn" {
  type = string
}
variable "api_repository_url" {
  type = string
}
variable "api_log_group_name" {
  type = string
}
variable "rds_endpoint" {
  type = string
}
variable "rds_db_name" {
  type = string
}
variable "rds_username" {
  type = string
}
variable "rds_password" {
  type = string
}
variable "image_cloudfront_domain" {
  type = string
}
variable "elasticache_host" {
  type = string
}
variable "image_bucket_name" {
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
variable "search_opensearch_endpoint" {
  type = string
}
variable "search_opensearch_id" {
  type = string
}
variable "search_opensearch_password" {
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
