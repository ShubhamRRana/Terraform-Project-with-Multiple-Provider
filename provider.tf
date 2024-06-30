provider "awscc" {
  region = "ap-south-1"
}

provider "aws" {
  region = "ap-south-1"
}

provider "aws" {
  region = "ap-southeast-1"
  alias  = "southeast1"
}