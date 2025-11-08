variable "project" {}
variable "vpc_id" {}
variable "alb_sg_id" {}
variable "public_subnets" {
  type = list(string)
}
