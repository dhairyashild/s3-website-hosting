output "mumbai_s3_website_endpoint" {
  description = "Mumbai S3 website endpoint"
  value       = "http://${aws_s3_bucket_website_configuration.static_website.website_endpoint}"
}

output "mumbai_domain_url" {
  description = "Mumbai region domain URL"
  value       = "http://mumbai.desai-devops.info"
}

output "cloudfront_url" {
  description = "CloudFront distribution URL"
  value       = "https://${aws_cloudfront_distribution.s3_distribution.domain_name}"
}

output "cdn_domain_url" {
  description = "CDN domain URL"
  value       = "https://cdn.desai-devops.info"
}

output "s3_bucket_name" {
  description = "S3 bucket name"
  value       = aws_s3_bucket.static_website.bucket
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.s3_distribution.id
}

output "route53_zone_id" {
  description = "Route 53 hosted zone ID"
  value       = data.aws_route53_zone.primary.zone_id
}
