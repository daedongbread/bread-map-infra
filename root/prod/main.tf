module "iam" {
  source = "../../modules/terraform-aws-iam"

  env                      = var.env
  image_bucket_arn         = module.s3.image_bucket_arn
  image_resizer_lambda_arn = module.lambda.image_resizer_arn
  opensearch_search_domain_name = module.opensearch.search_opensearch_domain_name
  # admin_codebuild_log_group_arn = module.cloudwatch.admin_codebuild_log_group_arn
  # admin_codebuild_name = module.codeseries.admin_codebuild_name
}

# module "codeseries" {
#   source = "../../modules/terraform-aws-codeseries"

#   env = var.env
#   github_organization = var.github_organization
#   domain = var.domain
#   admin_bucket_name = module.s3.admin_bucket_name
#   admin_cloudfront_id = module.cloudfront.admin_cloudfront_id
#   admin_codebuild_role_arn = module.iam.admin_codebuild_role_arn
#   admin_codepipeline_role_arn = module.iam.admin_codepipeline_role_arn
#   admin_codepipeline_bucket = module.s3.admin_codepipeline_bucket
# }

module "cloudwatch" {
  source = "../../modules/terraform-aws-cloudwatch"

  env = var.env
  api_cloudwatch_to_slack_lambda_name = module.lambda.api_cloudwatch_to_slack_name
  ip_update_to_slack_lambda_name      = module.lambda.ip_update_to_slack_name
  rds_slowquery_to_slack_lambda_name  = module.lambda.rds_slowquery_to_slack_name
  image_resizer_lambda_name           = module.lambda.image_resizer_name
  rds_identifier                      = module.rds.rds_identifier
}

module "lambda" {
  source = "../../modules/terraform-aws-lambda"

  providers = {
    aws.virginia = aws.virginia
  }

  env                              = var.env
  image_resizer_role_arn           = module.iam.image_resizer_role_arn
  api_log_group_arn = module.cloudwatch.api_log_group_arn
  api_log_group_name               = module.cloudwatch.api_log_group_name
  rds_slowquery_log_group_name     = module.cloudwatch.rds_slowquery_log_group_name
  rds_slowquery_log_group_arn = module.cloudwatch.rds_slowquery_log_group_arn
}

module "cloudfront" {
  source = "../../modules/terraform-aws-cloudfront"

  image_bucket_domain_name = module.s3.image_bucket_domain_name
  image_resizer_lambda_qualified_arn = module.lambda.image_resizer_qualified_arn
  # admin_bucket_domain_name = module.s3.admin_bucket_domain_name
  # domain = var.domain
  # admin_acm_arn = module.route53.admin_acm_certificate_arn
}

module "s3" {
  source = "../../modules/terraform-aws-s3"

  env                     = var.env
  domain                  = var.domain
  image_cloudfront_domain = module.cloudfront.image_cloudfront_domain
  image_cloudfront_arn    = module.cloudfront.image_cloudfront_arn
  image_resizer_role_arn  = module.iam.image_resizer_role_arn
  # admin_cloudfront_arn = module.cloudfront.admin_cloudfront_arn
}

module "vpc" {
  source = "../../modules/terraform-aws-vpc"

  env                = var.env
  availability_zones = var.availability_zones
  vpc_cidr           = var.vpc_cidr
  image_bucket_arn   = module.s3.image_bucket_arn
  ecs_task_role_arn  = module.iam.ecs_task_role_arn
}

module "security_group" {
  source = "../../modules/terraform-aws-security-group"

  env    = var.env
  vpc_id = module.vpc.vpc_id
}

module "lb" {
  source = "../../modules/terraform-aws-lb"

  env                        = var.env
  vpc_id                     = module.vpc.vpc_id
  lb_pub_subnet_ids          = module.vpc.lb_pub_subnet_ids
  pub_alb_security_group_id  = module.security_group.pub_alb_security_group_id
  domain_acm_certificate_arn = module.route53.domain_acm_certificate_arn
}

module "route53" {
  source = "../../modules/terraform-aws-route53"

  env              = var.env
  domain           = var.domain
  pub_alb_dns_name = module.lb.pub_alb_dns_name
  pub_alb_zone_id  = module.lb.pub_alb_zone_id
  # admin_cloudfront_domain = module.cloudfront.admin_cloudfront_domain
  # admin_cloudfront_zone_id = module.cloudfront.admin_cloudfront_zone_id
}

module "rds" {
  source = "../../modules/terraform-aws-rds"

  env                   = var.env
  rds_security_group_id = module.security_group.rds_security_group_id
  db_prv_subnet_ids     = module.vpc.db_prv_subnet_ids
  rds_password          = var.rds_password
}

module "elasticache" {
  source = "../../modules/terraform-aws-elasticache"

  env                     = var.env
  redis_security_group_id = module.security_group.redis_security_group_id
  db_prv_subnet_ids       = module.vpc.db_prv_subnet_ids
}

module "ec2" {
  source = "../../modules/terraform-aws-ec2"

  env                           = var.env
  instance_type                 = var.instance_type
  ecs_security_group_id         = module.security_group.ecs_security_group_id
  ecs_instance_profile_arn      = module.iam.ecs_instance_profile_arn
  ecs_cluster_name              = module.ecs.cluster_name
  # ecs_cluster_name              = "prod-daedong"
  svc_pub_subnet_ids            = module.vpc.svc_pub_subnet_ids
  min_size                      = var.min_size
  max_size                      = var.max_size
  desired_capacity              = var.desired_capacity
  key_pair_name                 = var.key_pair_name
}

module "ecr" {
  source = "../../modules/terraform-aws-ecr"

  env = var.env
}

module "ecs" {
  source = "../../modules/terraform-aws-ecs"

  env                         = var.env
  api_target_group_arn        = module.lb.api_target_group_arn
  ecs_task_role_arn           = module.iam.ecs_task_role_arn
  ecs_task_execution_role_arn = module.iam.ecs_task_execution_role_arn
  api_repository_url          = module.ecr.api_repository_url
  api_log_group_name          = module.cloudwatch.api_log_group_name
  rds_endpoint = module.rds.rds_address
  rds_db_name = module.rds.rds_db_name
  rds_username = module.rds.rds_username
  rds_password = module.rds.rds_password
  image_cloudfront_domain = module.cloudfront.image_cloudfront_domain
  elasticache_host = module.elasticache.elasticache_host
  image_bucket_name = module.s3.image_bucket_name
  api_image_tag = var.api_image_tag
  api_cpu = var.api_cpu
  api_memory = var.api_memory
  search_opensearch_endpoint = module.opensearch.search_opensearch_endpoint
  search_opensearch_id = var.search_master_user_name
  search_opensearch_password = var.search_master_user_password
  sgis_key = var.sgis_key
  sgis_secret = var.sgis_secret
  jwt_key = var.jwt_key
  jwt_admin_key = var.jwt_admin_key
  firebase_projectid = var.firebase_projectid
  firebase_credentials = var.firebase_credentials
}

module "eventbridge" {
  source = "../../modules/terraform-aws-eventbridge"

  ecs_asg_name                  = module.ec2.ecs_asg_name
  ip_update_to_slack_lambda_arn = module.lambda.ip_update_to_slack_arn
  ecs_security_group_id         = module.security_group.ecs_security_group_id
  svc_pub_subnet_ids            = module.vpc.svc_pub_subnet_ids
  ecs_event_role_arn            = module.iam.ecs_event_role_arn
}

module "opensearch" {
  source = "../../modules/terraform-aws-opensearch"

  env = var.env
  search_master_user_name = var.search_master_user_name
  search_master_user_password = var.search_master_user_password
  opensearch_search_log_group_arn = module.cloudwatch.opensearch_search_log_group_arn
}

module "sqs" {
  source = "../../modules/terraform-aws-sqs"
}
