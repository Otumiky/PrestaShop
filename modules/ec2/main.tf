resource "aws_instance" "prestashop" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = var.public_subnet_id
  security_groups = [var.security_group_id]

  user_data = <<-EOT
              #!/bin/bash
              # Update system packages
              sudo yum update -y

              # Install Apache, MySQL client, PHP, and required PHP extensions
              sudo yum install -y httpd mysql php php-mysqlnd unzip wget

              # Download PrestaShop
              wget https://download.prestashop.com/download/releases/prestashop_1.7.8.7.zip

              # Unzip PrestaShop
              unzip prestashop_1.7.8.7.zip -d /var/www/html/prestashop

              # Set proper ownership and permissions
              sudo chown -R apache:apache /var/www/html/prestashop
              sudo chmod -R 755 /var/www/html/prestashop

              # Start Apache web server
              sudo systemctl start httpd

              # Enable Apache to start on boot
              sudo systemctl enable httpd

              EOT

  tags = {
    Name = "Prestashop"
  }
}