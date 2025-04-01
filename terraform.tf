# This config tells Terraform where to store your state and how to lock it.

terraform {
  backend "s3" {
    bucket         = "terraform-state-kjell"
    key            = "website/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

