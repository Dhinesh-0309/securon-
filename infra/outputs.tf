output "vpc_id" {
  value = module.vpc.vpc_id
}

output "alb_dns" {
  value = module.alb.alb_dns_name
}

output "ec2_asg_name" {
  value = module.ec2.asg_name
}

output "db_endpoint" {
  value = module.rds.db_endpoint
}
