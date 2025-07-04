output "public_instance_id" {
  description = "ID of the public EC2 instance"
  value       = aws_instance.public.id
}

output "public_instance_private_ip" {
  description = "Private IP of the public EC2 instance"
  value       = aws_instance.public.private_ip
}

output "public_instance_public_ip" {
  description = "Public IP of the public EC2 instance"
  value       = aws_instance.public.public_ip
}

output "public_instance_ip" {
  description = "Public IP of the public EC2 instance (alias for Ansible)"
  value       = aws_instance.public.public_ip
}

output "private_instance_ids" {
  description = "IDs of the private EC2 instances"
  value       = aws_instance.private[*].id
}

output "private_instance_private_ips" {
  description = "Private IPs of the private EC2 instances"
  value       = aws_instance.private[*].private_ip
}

output "private_instance_ips" {
  description = "Private IPs of the private EC2 instances (alias for Ansible)"
  value       = aws_instance.private[*].private_ip
}

output "database_instance_id" {
  description = "ID of the database EC2 instance"
  value       = aws_instance.database.id
}

output "database_instance_private_ip" {
  description = "Private IP of the database EC2 instance"
  value       = aws_instance.database.private_ip
}

output "database_instance_ip" {
  description = "Private IP of the database EC2 instance (alias for Ansible)"
  value       = aws_instance.database.private_ip
} 