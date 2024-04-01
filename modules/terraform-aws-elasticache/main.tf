resource "aws_elasticache_replication_group" "daedong_api" {
  engine               = "redis"
  description                = " "

  replication_group_id       = "${var.env}-daedong-api"

  multi_az_enabled           = false
  automatic_failover_enabled = false

  engine_version       = "7.1"
  port                 = 6379
  parameter_group_name = "default.redis7"
  node_type            = "cache.t2.micro"
  replicas_per_node_group = 0

	subnet_group_name = aws_elasticache_subnet_group.daedong_api.name

	security_group_ids = [var.redis_security_group_id]

	snapshot_retention_limit = 0
  auto_minor_version_upgrade = true
}

resource "aws_elasticache_subnet_group" "daedong_api" {
  name       = "${var.env}-daedong-api-subnet-group"
  subnet_ids = var.db_prv_subnet_ids
}