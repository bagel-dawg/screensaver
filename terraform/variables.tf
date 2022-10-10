variable "environment" {
  description = "Environment Classification"
  default     = "production"
}

variable "target_bucket" {
  description = "S3 bucket to drop images into"
  default     = "bageltech-io"
}

variable "target_bucket_subpath" {
  description = "S3 Subpath for images"
  default     = "images/"
}

variable "base_url" {
  description = "S3 Subpath for images"
  default     = "https://bageltech.io/images"
}