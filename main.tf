terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"  # Mumbai region
}

# Get the existing Route 53 hosted zone
data "aws_route53_zone" "primary" {
  name = "desai-devops.info."
}

# S3 Bucket for static website hosting in Mumbai region
resource "aws_s3_bucket" "static_website" {
  bucket = "s3web-ap-south-1.desai-devops.info"
}

# Enable static website hosting
resource "aws_s3_bucket_website_configuration" "static_website" {
  bucket = aws_s3_bucket.static_website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# Configure public access block
resource "aws_s3_bucket_public_access_block" "static_website" {
  bucket = aws_s3_bucket.static_website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Set bucket policy for public read access
resource "aws_s3_bucket_policy" "static_website" {
  bucket = aws_s3_bucket.static_website.id
  depends_on = [aws_s3_bucket_public_access_block.static_website]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.static_website.arn}/*"
      },
    ]
  })
}

# Upload index.html
resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.static_website.id
  key          = "index.html"
  source       = "index.html"
  content_type = "text/html"
  depends_on   = [aws_s3_bucket_policy.static_website]
}

# Upload error.html
resource "aws_s3_object" "error_html" {
  bucket       = aws_s3_bucket.static_website.id
  key          = "error.html"
  source       = "error.html"
  content_type = "text/html"
  depends_on   = [aws_s3_bucket_policy.static_website]
}

# Create Route 53 record pointing to Mumbai S3 website
resource "aws_route53_record" "website_mumbai" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "mumbai.desai-devops.info"
  type    = "A"

  alias {
    name                   = aws_s3_bucket_website_configuration.static_website.website_domain
    zone_id                = aws_s3_bucket.static_website.hosted_zone_id
    evaluate_target_health = false
  }
}

# Optional: Create CloudFront distribution for better global performance
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.static_website.bucket_regional_domain_name
    origin_id   = "S3-mumbai-${aws_s3_bucket.static_website.bucket}"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution for Mumbai S3 static website"
  default_root_object = "index.html"

  aliases = ["cdn.desai-devops.info"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-mumbai-${aws_s3_bucket.static_website.bucket}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_200"  # Includes Asia regions

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name        = "mumbai-s3-website-distribution"
    Environment = "production"
    Region      = "ap-south-1"
  }
}

# Route 53 record for CloudFront
resource "aws_route53_record" "cloudfront" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "cdn.desai-devops.info"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
