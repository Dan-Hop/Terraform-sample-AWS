terraform {
  backend "s3" {
    bucket = "aou-tf-state"
    key    = "cloud-networks"
    region = "eu-west-1"
  }
}

provider "aws" {
  region =  "${lookup(var.region_maps, terraform.workspace)}"
}
