resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.project}-db-subnet-group"
  subnet_ids = var.db_subnets

  tags = {
    Name = "${var.project}-db-subnet-group"
  }
}

resource "aws_db_instance" "db_instance" {
  identifier              = "${var.project}-db"
  allocated_storage       = 20
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  username                = var.db_username
  password                = var.db_password
  skip_final_snapshot     = true
  publicly_accessible     = false
  db_subnet_group_name    = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids  = [var.rds_sg_id]
  storage_encrypted       = true
}
