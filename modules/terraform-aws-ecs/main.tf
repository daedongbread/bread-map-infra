# main
locals {
  api_environment = [ # TODO
    {
      "name" : "JWT_KEY",
      "value" : "${var.jwt_key}"
    },
    {
      "name" : "JWT_ADMIN_KEY",
      "value" : "${var.jwt_admin_key}"
    },
    {
      "name" : "DB_URL",
      "value" : "jdbc:mysql://${var.rds_endpoint}/${var.rds_db_name}"
    },
    {
      "name" : "DB_USERNAME",
      "value" : "${var.rds_username}"
    },
    {
      "name" : "DB_PASSWORD",
      "value" : "${var.rds_password}"
    },
    {
      "name" : "S3_BUCKET",
      "value" : "${var.image_bucket_name}"
    },
    {
      "name" : "S3_REGION",
      "value" : "ap-northeast-2"
    },
    {
      "name" : "S3_DEFAULT_BUCKET_IMAGE",
      "value" : "images"
    },
    {
      "name" : "S3_DEFAULT_IMAGE_USER",
      "value" : "defaultImage/defaultUser"
    },
    {
      "name" : "S3_DEFAULT_IMAGE_FLAG",
      "value" : "defaultImage/defaultFlag"
    },
    {
      "name" : "S3_DEFAULT_IMAGE_LIKE",
      "value" : "defaultImage/defaultLike"
    },
    {
      "name" : "S3_DEFAULT_IMAGE_BREAD_ADD",
      "value" : "defaultImage/defaultBreadAdd"
    },
    {
      "name" : "S3_DEFAULT_IMAGE_BAKERY",
      "value" : "defaultImage/defaultBakery"
    },
    {
      "name" : "S3_DEFAULT_IMAGE_COMMENT",
      "value" : "defaultImage/defaultComment"
    },
    {
      "name" : "S3_DEFAULT_IMAGE_REPORT",
      "value" : "defaultImage/defaultReport"
    },
    {
      "name" : "S3_DEFAULT_IMAGE_CURATION",
      "value" : "defaultImage/defaultCuration"
    },
    {
      "name" : "S3_DEFAULT_IMAGE_EVENT",
      "value" : "defaultImage/defaultEvent"
    },
    {
      "name" : "S3_CLOUDFRONT",
      "value" : "https://${var.image_cloudfront_domain}" # TODO
    },
    {
      "name" : "REDIS_HOST",
      "value" : "${var.elasticache_host}"
    },
    {
      "name" : "REDIS_PORT",
      "value" : "6379"
    },
    {
      "name" : "REDIS_KEY_ACCESS",
      "value" : "accessToken"
    },
    {
      "name" : "REDIS_KEY_DELETE",
      "value" : "deleteUser"
    },
    {
      "name" : "REDIS_KEY_ADMIN_REFRESH",
      "value" : "adminRefreshToken"
    },
    {
      "name" : "REDIS_KEY_REFRESH",
      "value" : "refreshToken"
    },
    {
      "name" : "REDIS_KEY_USER_REVIEW",
      "value" : "userReviewTime"
    },
    {
      "name" : "REDIS_KEY_RECENT",
      "value" : "recentKeywords"
    },
    {
      "name" : "REDIS_KEY_PRODUCT_REVIEW",
      "value" : "productReviewTime"
    },
    {
      "name" : "REDIS_KEY_BAKERY_REVIEW",
      "value" : "bakeryReviewTime"
    },
    {
      "name" : "OPEN_SEARCH_HOST",
      "value" : "${var.search_opensearch_endpoint}"
    },
    {
      "name" : "OPEN_SEARCH_ID",
      "value" : "${var.search_opensearch_id}"
    },
    {
      "name" : "OPEN_SEARCH_PASSWORD",
      "value" : "${var.search_opensearch_password}"
    },
    {
      "name" : "SGIS_SRC",
      "value" : "5179"
    },
    {
      "name" : "SGIS_KEY",
      "value" : "${var.sgis_key}"
    },
    {
      "name" : "SGIS_SECRET",
      "value" : "${var.sgis_secret}"
    },
    {
      "name" : "SGIS_DST1",
      "value" : "4326"
    },
    {
      "name" : "SGIS_DST2",
      "value" : "4166"
    },
    {
      "name" : "GOOGLE_ID",
      "value" : "tmp"
    },
    {
      "name" : "KAKAO_ID",
      "value" : "tmp"
    },
    {
      "name" : "APPLE_ID",
      "value" : "tmp"
    },
    {
      "name" : "FIREBASE_PROJECTID",
      "value" : "${var.firebase_projectid}"
    },
    {
      "name" : "FIREBASE_CREDENTIALS",
      "value" : "${var.firebase_credentials}"
    },
    {
      "name" : "FIREBASE_SCOPE",
      "value" : "https://www.googleapis.com/auth/cloud-platform"
    },
    {
      "name" : "FIREBASE_MESSAGE_PATH_USER",
      "value" : "/user/"
    },
    {
      "name" : "FIREBASE_MESSAGE_PATH_REVIEW",
      "value" : "/review/"
    }
  ]
}

resource "aws_ecs_cluster" "daedong" {
  name = "${var.env}-daedong"
}

## api
resource "aws_ecs_service" "api" {
  cluster     = aws_ecs_cluster.daedong.id
  launch_type = "EC2"

  task_definition     = aws_ecs_task_definition.api.arn
  name                = "daedong-api"
  scheduling_strategy = "REPLICA"
  desired_count       = 1
  deployment_controller {
    type = "ECS"
  }
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  load_balancer {
    target_group_arn = var.api_target_group_arn
    container_name   = "daedong-api" // TODO
    container_port   = 8080          // TODO
  }
  health_check_grace_period_seconds = 300

  ordered_placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }
  ordered_placement_strategy {
    type  = "spread"
    field = "instanceId"
  }
}

resource "aws_ecs_task_definition" "api" {
  family = "daedong-api"

  requires_compatibilities = ["EC2"]
  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }
  network_mode       = "bridge"
  cpu                = var.api_cpu
  memory             = var.api_memory
  task_role_arn      = var.ecs_task_role_arn
  execution_role_arn = var.ecs_task_execution_role_arn

  container_definitions = jsonencode(
    [
      {
        name      = "daedong-api"
        image     = "${var.api_repository_url}:${var.api_image_tag}" // TODO
        essential = true
        portMappings = [
          {
            hostPort      = 0
            containerPort = 8080
            protocol      = "tcp"  # default
            appProtocol   = "http" # default
          }
        ]
        environment = local.api_environment

        logConfiguration = {
          logDriver = "awslogs"
          options = {
            "awslogs-group"         = "${var.api_log_group_name}"
            "awslogs-region"        = "ap-northeast-2"
            "awslogs-stream-prefix" = "ecs"
          }
        }

        entryPoint = [
          "java",
          "-jar",
          "-DSpring.profiles.active=prod",
          "/app.jar"
        ]
      }
    ]
  )
}
