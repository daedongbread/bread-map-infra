variable "env" {
    type = string
}
variable "redis_security_group_id" {
    type = string
}
variable "db_prv_subnet_ids" {
    type = list(string)
}