terraform {
  backend "s3" {
    bucket         = "terraform-tfstate-670151543201"
    key            = "cfgmgmtcmp-2019-iac-ci-cd"
    region         = "us-east-1"
    dynamodb_table = "terraform_locks"
  }
}
