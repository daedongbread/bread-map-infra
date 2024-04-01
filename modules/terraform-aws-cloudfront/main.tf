resource "aws_cloudfront_distribution" "image_cloudfront" {
  origin {
    domain_name = var.image_bucket_domain_name
    origin_id   = var.image_bucket_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.image_cloudfront_oac.id
  }

  default_cache_behavior {
    compress = true
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    
    forwarded_values {
      cookies {
        forward = "none"
      }

      query_string            = "true"
      query_string_cache_keys = ["h", "q", "w"]
    }

    min_ttl                = "1"
    default_ttl     = "86400"
    max_ttl                = "31536000"
    target_origin_id = var.image_bucket_domain_name

    lambda_function_association {
      event_type   = "origin-response"
      include_body = false
      lambda_arn   = "${var.image_resizer_lambda_qualified_arn}"
    }
  }

	price_class = "PriceClass_200"

	viewer_certificate {
    cloudfront_default_certificate = true
  }
  enabled             = true # ?
  http_version        = "http2"
  is_ipv6_enabled     = true

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["KR"]
    }
  }
}

resource "aws_cloudfront_origin_access_control" "image_cloudfront_oac" {
  name                              = var.image_bucket_domain_name // not neccessary
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# resource "aws_cloudfront_distribution" "admin_cloudfront" {
#   origin {
#     domain_name = "${var.admin_bucket_domain_name}"
#     origin_id   = "${var.admin_bucket_domain_name}"
#     origin_access_control_id = aws_cloudfront_origin_access_control.admin_cloudfront_oac.id
#   }

#   default_cache_behavior {
#     target_origin_id = "${var.admin_bucket_domain_name}"
#     compress = true
#     viewer_protocol_policy = "redirect-to-https"
#     allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
#     cached_methods   = ["GET", "HEAD"]

#     cache_policy_id            = "658327ea-f89d-4fab-a63d-7e88639e58f6" # Managed-CachingOptimized
#     response_headers_policy_id = "5cc3b908-e619-4b99-88e5-2cf7f45965bd" # CORS-With-Preflight
#   }

#   price_class = "PriceClass_200"
#   aliases = [format("%s.%s", "admin", "${var.domain}")]
#   viewer_certificate {
#       acm_certificate_arn            = "${var.admin_acm_arn}"
#       cloudfront_default_certificate = false
#       minimum_protocol_version       = "TLSv1.2_2021"
#       ssl_support_method             = "sni-only"
#   }
#   http_version        = "http2"
#   default_root_object = "index.html"
#   enabled             = true # ?
#   is_ipv6_enabled     = true

#   restrictions {
#     geo_restriction {
#       restriction_type = "whitelist"
#       locations        = ["KR"]
#     }
#   }

#   custom_error_response {
#     error_code            = 403
#     error_caching_min_ttl = 10
#     response_code         = 200
#     response_page_path    = "/index.html"
#   }
# }

# resource "aws_cloudfront_origin_access_control" "admin_cloudfront_oac" {
#   name                              = "${var.admin_bucket_domain_name}" // not neccessary
#   origin_access_control_origin_type = "s3"
#   signing_behavior                  = "always"
#   signing_protocol                  = "sigv4"
# }