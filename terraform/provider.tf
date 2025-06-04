
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.0.0-beta2"
    }
  }
}

provider "aws" {
  region = var.region
  //shared_credentials_file = "~/.aws/creds"
  //profile                 = "profilename"
}
