module "vpc" {
  source             = "../../modules/vpc"
  vpc_cidr           = "10.0.0.0/16"
  vpc_name           = "prestashop-vpc"
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets    = ["10.0.3.0/24", "10.0.4.0/24"]
  availability_zones = ["us-east-1a", "us-east-1b"]
}

module "ec2" {
  source           = "../../modules/ec2"
  ami_id           = "ami-04b4f1a9cf54c11d0" #Ubuntu Server 24.04 LTS (HVM)
  key_name         = "new_key"
  instance_type    = "t2.micro"
  security_group_id   = module.vpc.ec2_sg
  public_subnet_id = element(module.vpc.public_subnets, 0)
}

module "rds" {
  source              = "../../modules/rds"
  vpc_id              = module.vpc.vpc_id
  allocated_storage   = 20
  engine              = "mysql"
  engine_version      = "8.0"
  instance_class      = "db.t3.micro"
  db_name             = "prestashop_db"
  username            = "********"
  password            = "********"
  security_group_id   = module.vpc.rds_sg
  subnet_group_name   = "db-subnet-group"
  private_subnet_ids  = module.vpc.private_subnets
}
