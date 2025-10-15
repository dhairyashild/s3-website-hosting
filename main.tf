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

# Simple S3 Bucket for static website hosting in Mumbai
resource "aws_s3_bucket" "static_website" {
  bucket = "s3web-mumbai.desai-devops.info"
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

# Configure public access
resource "aws_s3_bucket_public_access_block" "static_website" {
  bucket = aws_s3_bucket.static_website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Simple bucket policy for public read
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
}

# Upload error.html
resource "aws_s3_object" "error_html" {
  bucket       = aws_s3_bucket.static_website.id
  key          = "error.html"
  source       = "error.html"
  content_type = "text/html"
}

# Route 53 record for Mumbai S3 - using different subdomain
resource "aws_route53_record" "website_mumbai" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "mumbai.desai-devops.info"  # Changed from s3web to mumbai
  type    = "A"

  alias {
    name                   = aws_s3_bucket_website_configuration.static_website.website_domain
    zone_id                = aws_s3_bucket.static_website.hosted_zone_id
    evaluate_target_health = false
  }
}
