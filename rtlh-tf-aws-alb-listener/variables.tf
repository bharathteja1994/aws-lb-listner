variable "tags" {
  description = "(Optional) A mapping of tags to assign to the bucket."
  type        = map(string)
  default     = {}
}

variable "context" {
  description = "(Optional) The context that the resource is deployed in. e.g. devops, logs, lake"
  type        = string
  default     = "01"
}

########################################## ALB Listener ###############################################

variable "alb_name" {
  description = "(Required) Name of the alb that the listener will be attached to"
  type        = string
}

variable "default_rule" {
  description = "(Required) The default rule to apply to the alb listener."
  type = list(object({
    type = string,
    authenticate_cognito = list(object({
      user_pool_arn       = string,
      user_pool_client_id = string,
      user_pool_domain    = string
    })),
    authenticate_oidc = list(object({
      authorization_endpoint = string,
      client_id              = string,
      client_secret          = string,
      issuer                 = string,
      token_endpoint         = string,
      user_info_endpoint     = string
    })),
    fixed_response = list(object({
      content_type = string
      status_code  = string
      message_body = string
    })),
    forward = list(object({
      arn                = string
      weight             = number
      stickiness_enabled = bool
      duration           = number
    })),
    redirect = list(object({
      status_code = string
      port        = optional(string)
      protocol    = optional(string)
      host        = optional(string)
      path        = optional(string)
      query       = optional(string)
    }))
  }))
  validation {
    error_message = "Var: default_rule must be greater or = than 1"
    condition     = length(var.default_rule) >= 1
  }
}


variable "protocal" {
  description = " (Optional) Protocol for connections from clients to the load balancer. Valid values are HTTPS, HTTP, TCP, TLS, UDP, TCP_UDP"
  default     = "HTTPS"
  type        = string
  validation {
    error_message = "Var: protocal vaild values are (HTTPS, HTTP, TCP, TLS, UDP, TCP_UDP)"
    condition     = contains(["HTTPS", "HTTP", "TCP", "TLS", "UDP", "TCP_UDP"], var.protocal)
  }
}

variable "certificate_arn" {
  description = "(Optional) ARN of the default SSL server certificate. Exactly one certificate is required if the protocol is HTTPS"
  type        = string
  nullable    = true
  default     = null
}

variable "port" {
  description = "(Optional) Port on which the load balancer is listening."
  type        = number
  default     = 80
}

variable "ssl_policy" {
  description = "(Optional) Name of the SSL Policy for the listener. Required if protocol is HTTPS"
  type        = string
  default     = "ELBSecurityPolicy-TLS-1-2-2017-01"

  validation {
    error_message = "Var: ssl_policy valid values are (ELBSecurityPolicy-TLS-1-2-2017-01, ELBSecurityPolicy-TLS-1-1-2017-01, ELBSecurityPolicy-2016-08)"
    condition     = contains(["ELBSecurityPolicy-2016-08", "ELBSecurityPolicy-TLS-1-1-2017-01", "ELBSecurityPolicy-TLS-1-2-2017-01"], var.ssl_policy)
  }
}


variable "load_balancer_arn" {
  description = "(Required) The ARN of the load balancer to attach the listener to."
  type        = string

}

variable "listener_rules" {
  description = "(Optional) The default rule to apply to the alb listener."
  nullable    = true
  default     = null
  type = list(object({
    name = string,
    type = string,
    authenticate_cognito = list(object({
      user_pool_arn       = string,
      user_pool_client_id = string,
      user_pool_domain    = string
    })),
    authenticate_oidc = list(object({
      authorization_endpoint = string,
      client_id              = string,
      client_secret          = string,
      issuer                 = string,
      token_endpoint         = string,
      user_info_endpoint     = string
    })),
    fixed_response = list(object({
      content_type = string
      message_body = string
      status_code  = string
    })),
    forward = list(object({
      arn                = string,
      weight             = number,
      stickiness_enabled = bool,
      duration           = number
    })),
    redirect = list(object({
      status_code = string,
      port        = optional(string),
      protocol    = optional(string),
      host        = optional(string),
      path        = optional(string),
      query       = optional(string)
    })),


    condition = set(object({
      host_header = list(string),
      http_header = list(object({
        http_header_name = string,
        values           = list(string)
      })),
      http_request_method = list(string),
      path_pattern        = list(string),
      source_ip           = list(string)
    }))
  }))
}
