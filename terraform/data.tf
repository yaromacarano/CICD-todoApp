data "aws_caller_identity" "current" {}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

locals {
  default_subnet_ids = sort(data.aws_subnets.default.ids)
  alb_subnet_ids     = slice(local.default_subnet_ids, 0, 2)
}
