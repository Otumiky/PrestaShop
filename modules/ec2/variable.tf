variable "ami_id" {}
variable "instance_type" {}
variable "public_subnet_id" {}
variable "security_group_id" {}
variable "key_name" {}
variable "user_data" {
  description = "User data script for EC2 instance provisioning"
  type        = string
  default     = <<EOF
#!/bin/bash
sudo apt update -y
sudo apt install apache2 mysql-client php libapache2-mod-php php-mysql unzip wget -y
sudo systemctl start apache2
sudo systemctl enable apache2
wget https://download.prestashop.com/download/releases/prestashop_1.7.8.7.zip
sudo unzip prestashop_1.7.8.7.zip -d /var/www/html/prestashop
sudo chown -R www-data:www-data /var/www/html/prestashop
sudo chmod -R 755 /var/www/html/prestashop
sudo systemctl restart apache2
EOF
}
