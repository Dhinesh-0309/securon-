# VPC
module "vpc" {
  source   = "./modules/vpc"
  vpc_cidr = "10.0.0.0/16"
  project  = var.project
}

# Security Groups
module "security_groups" {
  source = "./modules/security_groups"
  vpc_id = module.vpc.vpc_id
  project  = var.project
}

# ALB
module "alb" {
  source         = "./modules/alb"
  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets
  alb_sg_id      = module.security_groups.alb_sg_id
  project  = var.project
}

# EC2
module "ec2" {
  source           = "./modules/ec2"
  private_subnets  = module.vpc.private_subnets
  ec2_sg_id        = module.security_groups.ec2_sg_id
  key_name         = var.ec2_key_name
  ami_id           = "ami-0c02fb55956c7d316"
  target_group_arn = module.alb.target_group_arn
  project  = var.project
}

# RDS
module "rds" {
  source      = "./modules/rds"
  db_subnets  = module.vpc.private_subnets
  rds_sg_id   = module.security_groups.rds_sg_id
  db_username = var.db_username
  db_password = var.db_password
  project  = var.project
}

# S3
module "s3" {
  source      = "./modules/s3"
  bucket_name = var.s3_bucket_name
  project  = var.project
}
