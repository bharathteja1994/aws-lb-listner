terraform {
  required_version = ">=1.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.23.1"
    }
  }
}
module "alb" {
  source = "github.com/rio-tinto/rtlh-tf-aws-alb?ref=v0.0.6"

  subnet_ids                 = [data.aws_subnet.this.id, data.aws_subnet.sn02.id]
  enable_deletion_protection = false
  security_group_ids         = [data.aws_security_group.this.id]
  access_logs = [{
    bucket  = ""
    enabled = false
    folder  = ""
  }]
  connection_logs = [{
    bucket  = ""
    enabled = false
    folder  = ""
  }]
}

module "alb-tg" {
  source      = "github.com/rio-tinto/rtlh-tf-aws-alb-target?ref=v0.0.4"
  target_id   = data.aws_alb.this.id
  target_type = "alb"
  context     = "deleteme"
  port        = 80
  protocol    = "TCP"
  vpc_id      = data.aws_subnet.this.vpc_id
  health_check = [{
    enabled             = true
    path                = "/status"
    healthy_threshold   = 3
    interval            = 60
    port                = 80
    protocol            = "HTTP"
    unhealthy_threshold = 3
    timeout             = 30
  }]
}

module "alb_rule" {
  source   = "github.com/rio-tinto/rtlh-tf-aws-alb-listener?ref=v0.0.21"
  alb_name = module.alb.name
  protocal = "HTTP"
  default_rule = [
    { type = "fixed-response"
      fixed_response = [{
        content_type = "text/plain"
        status_code  = "201"
        message_body = "This is a test"
      }]
      authenticate_cognito = []
      authenticate_oidc    = []
      forward              = []
      redirect             = []
    }
  ]
  listener_rules = [
    {
      type                 = "forward"
      fixed_response       = []
      authenticate_cognito = []
      authenticate_oidc    = []
      forward = [{
        arn                = module.alb-tg.alb_target_group_arn
        weight             = 1
        stickiness_enabled = false
      duration = 30 }]
      redirect = []
      condition = [{
        path_pattern = ["/status/*"]
        host_header  = [""]
        http_header = [{
          http_header_name = null
          values           = null
        }]
        http_request_method = [""]
        query_string = [{
          key   = null
          value = null
        }]
        source_ip = [""]
      }]
    }

  ]
}