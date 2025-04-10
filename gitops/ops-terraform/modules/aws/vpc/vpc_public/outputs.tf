output "vpc_id" {
  value = aws_vpc.default.id
}

output "subnet_id" {
  value = aws_subnet.public_subnet.*.id
}

output "subnet_cidr_blocks_public" {
  value = aws_subnet.public_subnet.*.cidr_block
}
