# terraform {
#     required_providers {
#         aws = {
#             source                = "hashicorp/aws"
#             version               = "~> 4.0"
#             configuration_aliases = [ aws.virginia ]
#         }
#     }
# }

resource "aws_acm_certificate" "daedong" { // TODO
    count = var.env == "prod" ? 1 : 0
    domain_name   = var.domain
    key_algorithm = "RSA_2048"

    options {
        certificate_transparency_logging_preference = "ENABLED" // TODO
    }

    subject_alternative_names = ["*.${var.domain}", "${var.domain}"]
    validation_method         = "DNS"
}

data "aws_acm_certificate" "daedong" { // TODO
    count  = var.env == "stage" ? 1 : 0
    domain = var.domain
}
# resource "aws_acm_certificate" "admin_daedong" { // TODO
#     provider = aws.virginia

#     domain_name   = format("%s.%s", "admin", var.domain)
#     key_algorithm = "RSA_2048"

#     options {
#         certificate_transparency_logging_preference = "ENABLED" // TODO
#     }

#     validation_method         = "DNS"
# }

resource "aws_route53_zone" "daedong" {
    count = var.env == "prod" ? 1 : 0
    force_destroy = false
    name          = var.domain
}

data "aws_route53_zone" "daedong" {
    count = var.env == "stage" ? 1 : 0
    name          = var.domain
}

resource "aws_route53domains_registered_domain" "daedong" {
    count = var.env == "prod" ? 1 : 0
    domain_name = var.domain

    dynamic "name_server" {
        for_each = toset(aws_route53_zone.daedong[0].name_servers)
        content {
            name = name_server.value
        }
    }
}

# resource "aws_route53_record" "admin_daedong_cloudfront" {
#     alias {
#         evaluate_target_health = false
#         name                   = "${var.admin_cloudfront_domain}"
#         zone_id                = "${var.admin_cloudfront_zone_id}"
#     }

#     name                             = format("%s.%s", "admin", "${var.domain}")
#     type                             = "A"
#     zone_id                          = aws_route53_zone.daedong.zone_id
# }

resource "aws_route53_record" "api_daedong_alb" {
    alias {
        evaluate_target_health = true
        name                   = format("%s.%s", "dualstack", "${var.pub_alb_dns_name}")
        zone_id                = "${var.pub_alb_zone_id}"
    }

    name                       = format("%s.%s", "api", "${var.domain}")
    type                       = "A"
    zone_id                    = var.env == "prod" ? aws_route53_zone.daedong[0].zone_id : data.aws_route53_zone.daedong[0].zone_id
}

resource "aws_route53_record" "acm_certificate" {
    for_each = var.env == "prod" ? {
        for dvo in aws_acm_certificate.daedong[0].domain_validation_options : dvo.domain_name => {
            name   = dvo.resource_record_name
            record = dvo.resource_record_value
            type   = dvo.resource_record_type
        }
    } : {}

    allow_overwrite = true
    name            = each.value.name
    records         = [each.value.record]
    ttl             = 172800
    type            = each.value.type
    # zone_id         = aws_route53_zone.daedong[0].zone_id
    zone_id         = var.env == "prod" ? aws_route53_zone.daedong[0].zone_id : data.aws_route53_zone.daedong[0].zone_id
}

resource "aws_acm_certificate_validation" "acm_certificate" { // TODO
    count = var.env == "prod" ? 1 : 0
    certificate_arn         = aws_acm_certificate.daedong[0].arn
    validation_record_fqdns = [for record in aws_route53_record.acm_certificate : record.fqdn]
}
