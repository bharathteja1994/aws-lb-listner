locals {
  workspace     = split("-", terraform.workspace)
  name          = format("albr-%s-%s-aws-%s-%s-%s", local.workspace[1], local.workspace[2], local.workspace[4], local.workspace[5], var.context)
  listener_tags = merge(var.tags, { Name = local.name })

}
