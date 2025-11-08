terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.5.0"
}

provider "aws" {
  region                      = "us-east-1"
  access_key                  = "FAKEACCESSKEY"
  secret_key                  = "FAKESECRETKEY"

  # Offline / simulation settings
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  max_retries                 = 0

  endpoints {
    sts = "http://localhost"
    ec2 = "http://localhost"
    s3  = "http://localhost"
    rds = "http://localhost"
  }
}
