locals {
    http_ingress = {
        description = "for http port"
        protocol    = "tcp"
        from_port   = 80
        to_port     = 80
        cidr_blocks = ["0.0.0.0/0"]
    }

    https_ingress = {
        description = "for https port"
        protocol    = "tcp"
        from_port   = 443
        to_port     = 443
        cidr_blocks = ["0.0.0.0/0"]
    }

    default_egress = {
        protocol    = "-1"
        from_port   = 0
        to_port     = 0
        cidr_blocks = ["0.0.0.0/0"]
    }
}


resource "aws_security_group" "pub_alb" {
    name        = "${var.env}-bibeop-pub-alb"
    description = "security group for public alb"
    vpc_id      = var.vpc_id

    ingress {
        description = local.http_ingress.description
        protocol    = local.http_ingress.protocol
        from_port   = local.http_ingress.from_port
        to_port     = local.http_ingress.to_port
        cidr_blocks = local.http_ingress.cidr_blocks
    }

    ingress {
        description = local.https_ingress.description
        protocol    = local.https_ingress.protocol
        from_port   = local.https_ingress.from_port
        to_port     = local.https_ingress.to_port
        cidr_blocks = local.https_ingress.cidr_blocks
    }

    egress {
        protocol    = local.default_egress.protocol
        from_port   = local.default_egress.from_port
        to_port     = local.default_egress.to_port
        cidr_blocks = local.default_egress.cidr_blocks
    }
}

resource "aws_security_group" "ecs" {
    name        = "${var.env}-bibeop-ecs"
    description = "security group for ecs"
    vpc_id      = var.vpc_id

    ingress {
        description = "for alb port"
        from_port   = 49153
        to_port     = 65535
        protocol    = "tcp"
        security_groups = [aws_security_group.pub_alb.id]
    }

    ingress {
        description = "for ssh"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"] // TODO
    }

    egress {
        protocol    = local.default_egress.protocol
        from_port   = local.default_egress.from_port
        to_port     = local.default_egress.to_port
        cidr_blocks = local.default_egress.cidr_blocks
    }
}

resource "aws_security_group" "rds" {
    name        = "${var.env}-bibeop-rds"
    description = "security group for rds"
    vpc_id      = var.vpc_id

    ingress {
        description = "for mysql"
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        security_groups = [aws_security_group.ecs.id]
    }

    egress {
        protocol    = local.default_egress.protocol
        from_port   = local.default_egress.from_port
        to_port     = local.default_egress.to_port
        cidr_blocks = local.default_egress.cidr_blocks
    }
}

resource "aws_security_group" "redis" {
    name        = "${var.env}-bibeop-redis"
    description = "security group for redis"
    vpc_id      = var.vpc_id

    ingress {
        description = "for redis"
        from_port   = 6379
        to_port     = 6379
        protocol    = "tcp"
        security_groups = [aws_security_group.ecs.id]
    }

    egress {
        protocol    = local.default_egress.protocol
        from_port   = local.default_egress.from_port
        to_port     = local.default_egress.to_port
        cidr_blocks = local.default_egress.cidr_blocks
    }
}