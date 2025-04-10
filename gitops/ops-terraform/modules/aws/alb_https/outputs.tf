output "alb_name" {
  value = aws_lb.alb.name
}
output "alb_tg_id" {
  value = aws_lb_target_group.default.id
}