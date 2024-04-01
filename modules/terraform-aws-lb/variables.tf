variable "env" {
    type = string
}
variable "vpc_id" {
    type = string
}
variable "lb_pub_subnet_ids" {
    type = list(string)
}
variable "pub_alb_security_group_id" {
    type = string
}
variable "domain_acm_certificate_arn" {
    type = string
}
