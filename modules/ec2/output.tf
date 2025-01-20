output "ec2_public_ip" {
  value = aws_instance.prestashop.public_ip
}