locals {
    alb_type = "application"
    port = {
        http = 80
        https = 443
    }
    protocol = {
        http = "HTTP"
        https = "HTTPS"
    }
}

resource "aws_lb_target_group" "api" {
    target_type = "instance" # default
    name     = "${var.env}-api"
    port     = local.port.http
    protocol = local.protocol.http
    vpc_id   = "${var.vpc_id}"

    health_check {
        enabled             = true
        protocol            = local.protocol.http
        path                = "/v1/actuator/health"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 5
        timeout             = 30
        interval            = 60
    }
}

resource "aws_lb" "daedong" {
    load_balancer_type               = local.alb_type

    name                             = "${var.env}-daedong" 
    internal                         = false
    ip_address_type                  = "ipv4"

    subnets                          = var.lb_pub_subnet_ids // a, c
    enable_cross_zone_load_balancing = true
    security_groups                  = ["${var.pub_alb_security_group_id}"]
}

resource "aws_lb_listener" "https_daedong" {
    load_balancer_arn    = aws_lb.daedong.arn
    port                 = local.port.https
    protocol             = local.protocol.https

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.api.arn
    }

    ssl_policy           = "ELBSecurityPolicy-TLS13-1-2-2021-06"
    certificate_arn      = "${var.domain_acm_certificate_arn}"
}

resource "aws_lb_listener" "http_daedong" {
    load_balancer_arn    = aws_lb.daedong.arn
    port                 = local.port.http
    protocol             = local.protocol.http

    default_action {
        type = "redirect"

        redirect {
            port        = local.port.https
            protocol    = local.protocol.https
            status_code = "HTTP_301"
        }
    }
}
