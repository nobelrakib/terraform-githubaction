# Security Group for Public EC2
resource "aws_security_group" "public" {
  name        = "${var.environment}-public-sg"
  description = "Security group for public EC2"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-public-sg"
  }
}

# Security Group for Private EC2
resource "aws_security_group" "private" {
  name        = "${var.environment}-private-sg"
  description = "Security group for private EC2"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-private-sg"
  }
}

# Public EC2 Instance
resource "aws_instance" "public" {
  ami                         = var.ami_id
  instance_type               = "t2.micro"
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [aws_security_group.public.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  tags = {
    Name = "${var.environment}-public-ec2"
  }
}

# Private EC2 Instances
resource "aws_instance" "private" {
  count                   = 2
  ami                    = var.ami_id
  instance_type          = "t2.medium"
  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = [aws_security_group.private.id]
  key_name               = var.key_name

  tags = {
    Name = "${var.environment}-private-ec2-${count.index + 1}"
  }
}

# Database EC2 Instance
resource "aws_instance" "database" {
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  subnet_id              = var.database_subnet_id
  vpc_security_group_ids = [aws_security_group.private.id]
  key_name               = var.key_name

  tags = {
    Name = "${var.environment}-database-ec2"
  }
} 