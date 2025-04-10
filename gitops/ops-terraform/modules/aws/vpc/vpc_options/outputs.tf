output "vpc_id" {
  value = aws_vpc.default.id
}

output "public_subnet_id" {
  value = aws_subnet.public_subnet.*.id
}

output "private_subnet_id" {
  value = aws_subnet.private_subnet.*.id
}

output "subnet_cidr_blocks_public" {
  value = aws_subnet.public_subnet.*.cidr_block
}

output "subnet_cidr_blocks_private" {
  value = aws_subnet.private_subnet.*.cidr_block
}