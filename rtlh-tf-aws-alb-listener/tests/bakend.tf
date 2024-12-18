
# tests/backend.tf

### tf workspace to be used for tests purposes: ws-rtlh-shr-aws-syd-sbx-test

terraform {
  backend "s3" {
    bucket  = "s3-rtlh-sbx-tf-state"
    encrypt = true
    key     = "playground/tf_state_key"
    region  = "ap-southeast-2"
  }
  required_version = ">= 1.0.0"
}
