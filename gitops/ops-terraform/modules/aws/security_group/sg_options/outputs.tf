output "ec2_sg_id" {
  value = aws_security_group.ec2_sg.id
}

output "ec2_sg_name" {
  value = aws_security_group.ec2_sg.name
}