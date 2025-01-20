output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnets" {
  value = aws_subnet.public[*].id
}

output "private_subnets" {
  value = aws_subnet.private[*].id
}
output "ec2_sg" {
  value = aws_security_group.ec2_sg.id
}
output "rds_sg" {
  value = aws_security_group.rds_sg.id
}