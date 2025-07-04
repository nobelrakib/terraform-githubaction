output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "subnet_ids" {
  description = "Map of subnet IDs by type"
  value       = module.vpc.subnet_ids
}

output "nat_gateway_ip" {
  description = "The public IP address of the NAT Gateway"
  value       = module.vpc.nat_gateway_ip
}

# EC2 Instance Outputs for Ansible
output "public_instance_ip" {
  description = "Public IP address of the public EC2 instance"
  value       = module.ec2.public_instance_ip
}

output "private_instance_ips" {
  description = "Private IP addresses of the private EC2 instances"
  value       = module.ec2.private_instance_ips
}

output "database_instance_ip" {
  description = "Private IP address of the database EC2 instance"
  value       = module.ec2.database_instance_ip
} 
