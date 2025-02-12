
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.86.1"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  //shared_credentials_file = "~/.aws/creds"
  //profile                 = "profilename"
}
