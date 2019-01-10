variable "region_maps" {
  type = "map"
  default = {
    aws_dublin_dev = "eu-west-1"
    aws_dublin_prod = "eu-west-1"
    aws_london_dev = "eu-west-2"
    aws_london_prod = "eu-west-2"
  }
}

variable "network_scope" {
  type = "map"
  default = {
    aws_dublin_dev = "172.25.0.0/20"
    aws_dublin_prod = "172.25.4.0/20"
#    aws_london_dev = "172.25.8.0/20"
#    aws_london_prod = "172.25.12.0/20"
#    aws_frankfurt_dev = "172.25.16.0/20"
#    aws_frankfurt_prod = "172.25.20.0/20"
#    aws_california_dev =  "172.26.0.0/20"
#    aws_california_prod = "172.26.4.0/20"
#    aws_oregon_dev = "172.26.8.0/20"
#    aws_oregon_prod = "172.26.12.0/20"
#    aws_virginia_dev = "172.26.16.0/20"
#    aws_virginia_prod = "172.26.20.0/20"
#    aws_ohio_dev = "172.26.24.0/20"
#    aws_ohio_prod = "172.26.28.0/20"
#    baidu_beijing_dev = "172.29.0.0/16"
#    baidu_beijing_prod = "172.29.0.0/16"
  }
}

variable "subnet_scope" {
  type = "map"
  default = {
    aws_dublin_dev = {
     a_public = "172.25.0.0/24"
     a_private = "172.25.1.0/24"
     b_public = "172.25.2.0/24"
     b_private = "172.25.3.0/24"
    }

    aws_dublin_prod = {
      a_public = "172.25.4.0/24"
      a_private = "172.25.5.0/24"
      b_public = "172.25.6.0/24"
      b_private = "172.25.7.0/24"
    }

    aws_london_dev = {
      a_public = "172.25.8.0/24"
      a_private = "172.25.9.0/24"
      b_public = "172.25.10.0/24"
      b_private = "172.25.11.0/24"
    }

    aws_london_prod = {
      a_public = "172.25.12.0/24"
      a_private = "172.25.13.0/24"
      b_public = "172.25.14.0/24"
      b_private = "172.25.15.0/24"
    }
  }
}

## AWS Hosted Data
data "aws_availability_zones" "available" {}
