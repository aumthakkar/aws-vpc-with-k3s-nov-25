resource "aws_db_instance" "my_db_instance" {
  allocated_storage = var.db_storage # 10Gi

  db_name = var.db_name

  identifier     = var.db_identifier
  instance_class = var.db_instance_class

  username = var.db_username
  password = var.db_password

  engine         = var.db_engine
  engine_version = var.db_engine_version


  db_subnet_group_name   = aws_db_subnet_group.my_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.my_public_security_group["rds"].id]

  skip_final_snapshot = var.skip_db_final_snapshot

  tags = {
    Name = "${var.name_prefix}-rds-mysql-db-instance"
  }
}