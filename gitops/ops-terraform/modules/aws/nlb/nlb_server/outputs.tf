output "load_balancer_arn" {
  value = aws_lb.nlb_ec2.arn
}

output "load_balancer_id" {
  value = aws_lb.nlb_ec2.id
}