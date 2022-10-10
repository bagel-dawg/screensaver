terraform {
  backend "s3" {
    bucket  = "screensaver-terraform"
    key     = "tfstate"
    region  = "us-east-1"
  }
}
