output "api_target_group_arn" {
    value = aws_lb_target_group.api.arn
}
output "pub_alb_dns_name" {
    value = aws_lb.daedong.dns_name
}
output "pub_alb_zone_id" {
    value = aws_lb.daedong.zone_id
}
