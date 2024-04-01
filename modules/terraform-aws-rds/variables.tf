variable "env" {
    type = string
}
variable "rds_security_group_id" {
    type = string
}
variable "db_prv_subnet_ids" {
    type = list(string)
}
variable "rds_password" {
    type = string
}
