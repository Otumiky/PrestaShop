resource "aws_db_instance" "main" {
  allocated_storage       = var.allocated_storage
  engine                  = var.engine
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  db_name                 = var.db_name
  username                = var.username
  password                = var.password
  publicly_accessible     = false
  vpc_security_group_ids  = [var.security_group_id]
  db_subnet_group_name    = aws_db_subnet_group.main.name
  skip_final_snapshot     = true

  tags = {
    Name = "prestashop-rds"
  }
}


resource "aws_db_subnet_group" "main" {
  name       = "prestashop-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "prestashop-db-subnet-group"
  }
}