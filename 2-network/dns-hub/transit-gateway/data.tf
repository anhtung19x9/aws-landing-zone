data "aws_availability_zones" "available" {}
data "terraform_remote_state" "remote" {
  backend = "s3"
  config = {
    bucket = local.lz_config.global.lz_state_bucket
    key    = "1-org/terraform.tfstate"
    region = local.lz_config.global.home_region
  }
}

data "terraform_remote_state" "two-network" {
  backend = "s3"
  config = {
    bucket = local.lz_config.global.lz_state_bucket
    key    = "2-network/network-hub/transit-gateway/terraform.tfstate"
    region = local.lz_config.global.home_region
  }
}

data "terraform_remote_state" "dns-hub-vpc" {
  backend = "s3"
  config = {
    bucket = local.lz_config.global.lz_state_bucket
    key    = "2-network/dns-hub/vpc/terraform.tfstate"
    region = local.lz_config.global.home_region
  }
}