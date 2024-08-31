

####### db subents ######

resource "aws_db_subnet_group" "main" {
  name       = "main"
  subnet_ids = [
    aws_subnet.private_az1.id,
    aws_subnet.private_az2.id
  ]

  tags = {
    Name = var.name
  }
}

##### db #####

resource "aws_db_instance" "main" {
  engine            = "postgres"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  engine_version         = "16.3"
  db_name           = "${var.name}-postgresql"
  username          = "admin"
  password          = "yourpassword"
  parameter_group_name = "default.mysql8.0"
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name = aws_db_subnet_group.main.name
  skip_final_snapshot = true

  # Storage options
  storage_type      = "gp3"
  backup_retention_period = 7
  multi_az          = false
  publicly_accessible = false
  deletion_protection = false
}