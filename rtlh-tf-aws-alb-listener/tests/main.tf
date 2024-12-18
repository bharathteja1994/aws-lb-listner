module "alb" {
  source                     = "github.com/rio-tinto/rtlh-tf-aws-alb?ref=v1.1.2"
  context                    = "test"
  enable_deletion_protection = false
  security_group_ids         = var.security_group_ids
  subnets                    = var.subnet_ids
}
module "alb-target" {
  source                     = "github.com/rio-tinto/rtlh-tf-aws-alb?ref=v1.1.2"
  context                    = "01"
  enable_deletion_protection = false
  security_group_ids         = var.security_group_ids
  subnets                    = var.subnet_ids
}

module "alb-redirect" {
  source                     = "github.com/rio-tinto/rtlh-tf-aws-alb?ref=v1.1.2"
  context                    = "02"
  enable_deletion_protection = false
  security_group_ids         = var.security_group_ids
  subnets                    = var.subnet_ids
}

module "ec2_instance_test-01" {
  source          = "github.com/rio-tinto/rtlh-tf-aws-ec2?ref=v1.2.3"
  context         = "tst"
  image           = var.image
  instance_type   = "t2.medium"
  subnet_ID       = "subnet-09fb13bd6586bfb4e"
  iam_role        = "ec2-iam-rtlh-sbx-devops"
  monitoring      = false
  security_groups = [module.security_group_ec2_test-01.security_group_id]
  volume_size     = var.volume_size
  tags = {
    use-case = "A basic On-Demand EC2 instance with IAM instance profile"
  }
}

module "security_group_ec2_test-01" {
  source            = "github.com/rio-tinto/rtlh-tf-aws-sg?ref=v1.0.1"
  group_description = "RTLH EC2 Instance Test"
  vpc_id            = var.vpc_id

  tags = {
    use-case = "A basic On-Demand EC2 instance with IAM instance profile"
  }

  ingress_rules = [
    {
      description = "Allows inbound HTTP access from any internal address"
      cidr_ipv4   = "10.0.0.0/8"
      from_port   = 80
      to_port     = 80
      ip_protocol = "6"
    },
    {
      description = "Allows inbound SSH access from any internal address"
      cidr_ipv4   = "10.0.0.0/8"
      from_port   = 22
      to_port     = 22
      ip_protocol = "6"
    }
  ]

  egress_rules = [
    {
      description = "Allows all outbound traffic any protocol"
      cidr_ipv4   = "0.0.0.0/0"
      from_port   = "-1" # All ports
      to_port     = "-1" # All ports
      ip_protocol = "-1" # All protocols
    },
    {
      description    = "Allows outbound HTTPS traffic to AWS S3 Gateway"
      prefix_list_id = "pl-6ca54005"
      from_port      = 443
      to_port        = 443
      ip_protocol    = "6"
    }
  ]

}

module "alb-instance" {
  source      = "github.com/rio-tinto/rtlh-tf-aws-alb-target?ref=v1.0.2"
  target_id   = module.ec2_instance_test-01.ec2_id
  target_type = "instance"
  context     = "03"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
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
  source            = ".//.."
  alb_name          = module.alb.name
  load_balancer_arn = module.alb.arn
  protocal          = "HTTP"
  default_rule = [{
    type = "fixed-response"
    fixed_response = [{
      content_type = "text/plain"
      status_code  = "201"
      message_body = "This is a test"
    }]
    authenticate_cognito = []
    authenticate_oidc    = []
    forward              = []
    redirect             = []
  }]
  listener_rules = [
    {
      name                 = "rule1"
      type                 = "forward"
      fixed_response       = []
      authenticate_cognito = []
      authenticate_oidc    = []
      forward = [{
        arn                = module.alb-instance.alb_target_group_arn
        weight             = 1
        stickiness_enabled = false
        duration           = 30
      }]
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
module "alb_listener_fixed_response" {
  source            = ".//.."
  alb_name          = module.alb-target.name
  load_balancer_arn = module.alb-target.arn
  protocal          = "HTTP"
  default_rule = [{
    type = "fixed-response"
    fixed_response = [{
      content_type = "text/plain"
      status_code  = "200"
      message_body = "Fixed response action deployed"
    }]
    authenticate_cognito = []
    authenticate_oidc    = []
    forward              = []
    redirect             = []
  }]
  listener_rules = [
    {
      name                 = "fixed_response_rule"
      type                 = "fixed-response"
      fixed_response = [{
        content_type = "text/plain"
        status_code  = "200"
        message_body = "Fixed response action deployed"
      }]
      authenticate_cognito = []
      authenticate_oidc    = []
      forward              = []
      redirect             = []
      condition = [{
        path_pattern = ["/*"]
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
module "alb_listener_redirect" {
  source            = ".//.."
  alb_name          = module.alb-redirect.name
  load_balancer_arn = module.alb-redirect.arn
  protocal          = "HTTP"
  port              = 80
  default_rule = [{
    type                 = "redirect"
    authenticate_cognito = []
    authenticate_oidc    = []
    fixed_response       = []
    forward             = []
    redirect = [{
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }]
  }]
  
  listener_rules = []
}
