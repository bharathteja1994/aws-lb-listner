
# tests/provider.tf

terraform {
  required_version = ">=1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.23.1,<=5.70.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }
  }

}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Region      = var.region
      CostCode    = var.cost_code
      Requestor   = var.requestor
      Approver    = var.approver
      SubDomain   = var.sub_domain
      Application = var.application
      Owner       = var.owner
      Environment = var.environment
    }
  }

}
