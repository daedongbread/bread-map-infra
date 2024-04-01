output "elasticache_host" {
    value = aws_elasticache_replication_group.daedong_api.primary_endpoint_address
}