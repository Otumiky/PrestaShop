variable "allocated_storage" {
  default = 20
}

variable "engine" {
  default = "mysql"
}

variable "engine_version" {
  default = "8.0"
}

variable "instance_class" {
  default = "db.t3.micro"
}

variable "db_name" {
  default = "prestashop_db"
}

variable "username" {}

variable "password" {}

variable "security_group_id" {}

variable "subnet_group_name" {}

variable "private_subnet_ids" {}
variable "vpc_id" {
  description = "The ID of the VPC where RDS will be deployed"
  type        = string
}