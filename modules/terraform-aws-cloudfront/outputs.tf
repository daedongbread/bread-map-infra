output "image_cloudfront_domain" {
    value = aws_cloudfront_distribution.image_cloudfront.domain_name
}
output "image_cloudfront_arn" {
    value = aws_cloudfront_distribution.image_cloudfront.arn
}
# output "admin_cloudfront_domain" {
#     value = aws_cloudfront_distribution.admin_cloudfront.domain_name
# }
# output "admin_cloudfront_zone_id" {
#     value = aws_cloudfront_distribution.admin_cloudfront.hosted_zone_id
# }
# output "admin_cloudfront_arn" {
#     value = aws_cloudfront_distribution.admin_cloudfront.arn
# }
# output "admin_cloudfront_id" {
#     value = aws_cloudfront_distribution.admin_cloudfront.id
# }
