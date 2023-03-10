variable "AWS_ACCESS_KEY" {
  type = string
}
variable "AWS_SECRET_KEY" {
  type = string
}

# variable "MONGODB_PUBLIC_KEY" {
#   type = string
# }
# variable "MONGODB_PRIVATE_KEY" {
#   type = string
# }

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region     = "us-east-1"
  access_key = var.AWS_ACCESS_KEY
  secret_key = var.AWS_SECRET_KEY
}

# provider "mongodbatlas" {
#   public_key = var.MONGODB_PUBLIC_KEY
#   private_key  = var.MONGODB_PRIVATE_KEY
# }