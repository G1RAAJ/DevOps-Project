# rds.tf (Production-Style Example – PostgreSQL)
# ---------------- RDS Security Group ----------------
resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Allow DB access from app servers"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description     = "Allow PostgreSQL from App SG"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "RDS-SG"
  }
}

# ---------------- DB Subnet Group ----------------
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [
    aws_subnet.private_1.id,
    aws_subnet.private_2.id
  ]

  tags = {
    Name = "RDS-Subnet-Group"
  }
}

# ---------------- RDS Instance ----------------
resource "aws_db_instance" "postgres_db" {
  identifier              = "app-postgres-db"
  engine                  = "postgres"
  engine_version          = "15.4"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  storage_type            = "gp2"

  username                = var.db_username
  password                = var.db_password

  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]

  publicly_accessible     = false
  multi_az                = false
  skip_final_snapshot     = true

  tags = {
    Name = "App-Postgres-DB"
  }
}
