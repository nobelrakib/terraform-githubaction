variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the EC2 instances will be created"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block for security group rules"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID for public EC2 instance"
  type        = string
}

variable "private_subnet_id" {
  description = "Private subnet ID for private EC2 instances"
  type        = string
}

variable "database_subnet_id" {
  description = "Database subnet ID for database EC2 instance"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
  default     = "ami-0731becbf832f281e"  
}

variable "key_name" {
  description = "Name of the SSH key pair to use for EC2 instances"
  type        = string
} 