output "domain_acm_certificate_arn" {
    value = var.env == "prod" ? aws_acm_certificate.daedong[0].arn : data.aws_acm_certificate.daedong[0].arn
}
# output "admin_acm_certificate_arn" {
#     value = aws_acm_certificate.admin_daedong.arn
# }