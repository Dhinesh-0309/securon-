variable "project" {}
variable "private_subnets" {
  type = list(string)
}
variable "ec2_sg_id" {}
variable "key_name" {}
variable "ami_id" {}
variable "target_group_arn" {}
