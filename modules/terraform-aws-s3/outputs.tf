output "image_bucket_arn" {
    value = aws_s3_bucket.image_bucket.arn
}
output "image_bucket_name" {
    value = aws_s3_bucket.image_bucket.id
}
output "image_bucket_domain_name" {
    value = aws_s3_bucket.image_bucket.bucket_domain_name
}
# output "admin_bucket_name" {
#     value = aws_s3_bucket.admin_bucket.id
# }
# output "admin_bucket_domain_name" {
#     value = aws_s3_bucket.admin_bucket.bucket_domain_name
# }
# output "admin_codepipeline_bucket" {
#     value = aws_s3_bucket.admin_codepipeline_bucket.bucket
# }