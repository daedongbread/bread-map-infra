output "vpc_id" {
    value = aws_vpc.vpc.id
}
output "lb_pub_subnet_ids" {
    value = aws_subnet.lb_pub[*].id
}
output "svc_pub_subnet_ids" {
    value = aws_subnet.svc_pub[*].id
}
output "db_prv_subnet_ids" {
    value = aws_subnet.db_prv[*].id
}