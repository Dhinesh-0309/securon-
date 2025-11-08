variable "aws_region" {
  default = "us-east-1"
}

variable "aws_profile" {
  default = "default"
}

variable "project" {
  default = "securon"
}

variable "ec2_key_name" {
  default = "my-key"
}

variable "db_username" {
  default = "admin"
}

variable "db_password" {
  default = "SuperSecurePass123"
}

variable "s3_bucket_name" {
  default = "securon-app-storage"
}
