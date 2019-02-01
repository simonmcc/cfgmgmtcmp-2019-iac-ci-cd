terraform {
  backend "s3" {
    bucket         = "terraform-tfstate-670151543201"
    key            = "packer-vpc"
    region         = "us-east-1"
    dynamodb_table = "terraform_locks"
  }
}
