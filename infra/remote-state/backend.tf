# Terraform backend config

# infra/remote-state/backend.tf

terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"  # Change this
    key            = "ai-acc-stack/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"             # Change this
    encrypt        = true
  }
}
