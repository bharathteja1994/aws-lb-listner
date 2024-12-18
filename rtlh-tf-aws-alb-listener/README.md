<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >=5.23.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >=5.23.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_lb_listener.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |
| [aws_lb.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/lb) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_name"></a> [alb\_name](#input\_alb\_name) | (Required) Name of the alb that the listener will be attached to | `string` | n/a | yes |
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | (Optional) ARN of the default SSL server certificate. Exactly one certificate is required if the protocol is HTTPS | `string` | `null` | no |
| <a name="input_context"></a> [context](#input\_context) | (Optional) The context that the resource is deployed in. e.g. devops, logs, lake | `string` | `"01"` | no |
| <a name="input_default_rule"></a> [default\_rule](#input\_default\_rule) | (Required) The default rule to apply to the alb listener. | <pre>list(object({<br/>    type = string,<br/>    authenticate_cognito = list(object({<br/>      user_pool_arn       = string,<br/>      user_pool_client_id = string,<br/>      user_pool_domain    = string<br/>    })),<br/>    authenticate_oidc = list(object({<br/>      authorization_endpoint = string,<br/>      client_id              = string,<br/>      client_secret          = string,<br/>      issuer                 = string,<br/>      token_endpoint         = string,<br/>      user_info_endpoint     = string<br/>    })),<br/>    fixed_response = list(object({<br/>      content_type = string<br/>      status_code  = string<br/>      message_body = string<br/>    })),<br/>    forward = list(object({<br/>      arn                = string<br/>      weight             = number<br/>      stickiness_enabled = bool<br/>      duration           = number<br/>    })),<br/>    redirect = list(object({<br/>      status_code = string<br/>    }))<br/>  }))</pre> | n/a | yes |
| <a name="input_listener_rules"></a> [listener\_rules](#input\_listener\_rules) | (Optional) The default rule to apply to the alb listener. | <pre>list(object({<br/>    name = string,<br/>    type = string,<br/>    authenticate_cognito = list(object({<br/>      user_pool_arn       = string,<br/>      user_pool_client_id = string,<br/>      user_pool_domain    = string<br/>    })),<br/>    authenticate_oidc = list(object({<br/>      authorization_endpoint = string,<br/>      client_id              = string,<br/>      client_secret          = string,<br/>      issuer                 = string,<br/>      token_endpoint         = string,<br/>      user_info_endpoint     = string<br/>    })),<br/>    fixed_response = list(object({<br/>      content_type = string<br/>      message_body = string<br/>      status_code  = string<br/>    })),<br/>    forward = list(object({<br/>      arn                = string,<br/>      weight             = number,<br/>      stickiness_enabled = bool,<br/>      duration           = number<br/>    })),<br/>    redirect = list(object({<br/>      status_code = string<br/>    })),<br/><br/><br/>    condition = set(object({<br/>      host_header = list(string),<br/>      http_header = list(object({<br/>        http_header_name = string,<br/>        values           = list(string)<br/>      })),<br/>      http_request_method = list(string),<br/>      path_pattern        = list(string),<br/>      source_ip           = list(string)<br/>    }))<br/>  }))</pre> | `null` | no |
| <a name="input_port"></a> [port](#input\_port) | (Optional) Port on which the load balancer is listening. | `number` | `80` | no |
| <a name="input_protocal"></a> [protocal](#input\_protocal) | (Optional) Protocol for connections from clients to the load balancer. Valid values are HTTPS, HTTP, TCP, TLS, UDP, TCP\_UDP | `string` | `"HTTPS"` | no |
| <a name="input_ssl_policy"></a> [ssl\_policy](#input\_ssl\_policy) | (Optional) Name of the SSL Policy for the listener. Required if protocol is HTTPS | `string` | `"ELBSecurityPolicy-TLS-1-2-2017-01"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A mapping of tags to assign to the bucket. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_listener_arn"></a> [alb\_listener\_arn](#output\_alb\_listener\_arn) | n/a |
| <a name="output_alb_listener_id"></a> [alb\_listener\_id](#output\_alb\_listener\_id) | n/a |
<!-- END_TF_DOCS -->