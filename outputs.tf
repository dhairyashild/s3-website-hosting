output "website_url" {
  description = "Website URL"
  value       = "http://mumbai.desai-devops.info"
}

output "s3_endpoint" {
  description = "S3 website endpoint"
  value       = "http://${aws_s3_bucket_website_configuration.static_website.website_endpoint}"
}

output "bucket_name" {
  description = "S3 bucket name"
  value       = aws_s3_bucket.static_website.bucket
}

output "region" {
  description = "AWS region"
  value       = "ap-south-1"
}
