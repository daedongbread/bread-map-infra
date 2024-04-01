output "pub_alb_security_group_id" {
    value = aws_security_group.pub_alb.id
}
output "ecs_security_group_id" {
    value = aws_security_group.ecs.id
}
output "rds_security_group_id" {
    value = aws_security_group.rds.id
}
output "redis_security_group_id" {
    value = aws_security_group.redis.id
}
