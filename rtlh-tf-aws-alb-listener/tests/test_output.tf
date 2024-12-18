# tests/test_outputs.tf

output "target_name" {
  value = module.alb-instance.alb_target_group_name
}
