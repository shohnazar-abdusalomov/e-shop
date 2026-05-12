terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Uncomment to use S3 backend for remote state
  # backend "s3" {
  #   bucket         = "eshop-terraform-state"
  #   key            = "eshop/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "eshop-terraform-locks"
  # }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = "E-SHOP"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}
