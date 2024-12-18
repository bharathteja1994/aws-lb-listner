resource "aws_lb_listener" "this" {
  dynamic "default_action" {
    for_each = var.default_rule
    content {
      type = default_action.value["type"]
      dynamic "authenticate_cognito" {
        for_each = default_action.value["authenticate_cognito"]
        content {
          user_pool_arn       = authenticate_cognito.value["user_pool_arn"]
          user_pool_client_id = authenticate_cognito.value["user_pool_client_id"]
          user_pool_domain    = authenticate_cognito.value["user_pool_domain"]
        }
      }

      dynamic "authenticate_oidc" {
        for_each = default_action.value["authenticate_oidc"]
        content {
          authorization_endpoint = authenticate_oidc.value["authorization_endpoint"]
          client_id              = authenticate_oidc.value["client_id"]
          client_secret          = authenticate_oidc.value["client_secret"]
          issuer                 = authenticate_oidc.value["issuer"]
          token_endpoint         = authenticate_oidc.value["token_endpoint"]
          user_info_endpoint     = authenticate_oidc.value["user_info_endpoint"]
        }
      }
      dynamic "fixed_response" {
        for_each = default_action.value["fixed_response"]
        content {
          content_type = fixed_response.value["content_type"]
          status_code  = fixed_response.value["status_code"]
          message_body = fixed_response.value["message_body"]
        }
      }
      dynamic "forward" {
        for_each = default_action.value["forward"]
        content {
          stickiness {
            duration = forward.value["duration"]
            enabled  = forward.value["stickiness_enabled"]
          }
          target_group {
            arn    = forward.value["arn"]
            weight = forward.value["weight"]
          }
        }
      }
      dynamic "redirect" {
        for_each = default_action.value["redirect"]
        content {
          status_code = redirect.value["status_code"]
          port        = lookup(redirect.value, "port", null)
          protocol    = lookup(redirect.value, "protocol", null)
          host        = lookup(redirect.value, "host", null)
          path        = lookup(redirect.value, "path", null)
          query       = lookup(redirect.value, "query", null)
        }
      }
    }
  }

  load_balancer_arn = var.load_balancer_arn
  certificate_arn   = var.protocal == "HTTPS" ? var.certificate_arn : null
  port              = var.port
  protocol          = var.protocal
  ssl_policy        = var.protocal == "HTTPS" ? var.ssl_policy : null
  tags              = local.listener_tags

}


###### 1 to many (listener to rule) ################

resource "aws_lb_listener_rule" "this" {
  count        = length(var.listener_rules) > 0 ? length(var.listener_rules) : 0
  listener_arn = aws_lb_listener.this.arn
  action {
    type = var.listener_rules[count.index].type
    dynamic "authenticate_cognito" {
      for_each = var.listener_rules[count.index].authenticate_cognito
      content {
        user_pool_arn       = authenticate_cognito.value["user_pool_arn"]
        user_pool_client_id = authenticate_cognito.value["user_pool_client_id"]
        user_pool_domain    = authenticate_cognito.value["user_pool_domain"]
      }
    }

    dynamic "authenticate_oidc" {
      for_each = var.listener_rules[count.index].authenticate_oidc
      content {
        authorization_endpoint = authenticate_oidc.value["authorization_endpoint"]
        client_id              = authenticate_oidc.value["client_id"]
        client_secret          = authenticate_oidc.value["client_secret"]
        issuer                 = authenticate_oidc.value["issuer"]
        token_endpoint         = authenticate_oidc.value["token_endpoint"]
        user_info_endpoint     = authenticate_oidc.value["user_info_endpoint"]
      }
    }
    dynamic "fixed_response" {
      for_each = var.listener_rules[count.index].fixed_response
      content {
        content_type = fixed_response.value["content_type"]
        status_code  = fixed_response.value["status_code"]
        message_body = fixed_response.value["message_body"]
      }
    }
    dynamic "forward" {
      for_each = var.listener_rules[count.index].forward
      content {
        stickiness {
          duration = forward.value["duration"]
          enabled  = forward.value["stickiness_enabled"]
        }
        target_group {
          arn    = forward.value["arn"]
          weight = forward.value["weight"]
        }
      }
    }
    dynamic "redirect" {
      for_each = var.listener_rules[count.index].redirect
      content {
        status_code = redirect.value["status_code"]
        port        = lookup(redirect.value, "port", null)
        protocol    = lookup(redirect.value, "protocol", null)
        host        = lookup(redirect.value, "host", null)
        path        = lookup(redirect.value, "path", null)
        query       = lookup(redirect.value, "query", null)
      }
    }

  }


  dynamic "condition" {
    for_each = var.listener_rules[count.index].condition
    content {


      path_pattern {
        values = condition.value["path_pattern"]
      }

    }
  }

  tags = merge(var.tags, { Name = var.listener_rules[count.index].name })
}


