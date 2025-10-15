variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"  # Mumbai region
}

variable "domain_name" {
  description = "Domain name for the website"
  type        = string
  default     = "desai-devops.info"
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
  default     = "s3web-ap-south-1.desai-devops.info"
}

variable "mumbai_subdomain" {
  description = "Subdomain for Mumbai region website"
  type        = string
  default     = "mumbai"
}

variable "cdn_subdomain" {
  description = "Subdomain for CloudFront CDN"
  type        = string
  default     = "cdn"
}
