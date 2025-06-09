output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "subnet_ids" {
  description = "Map of subnet IDs by type"
  value = {
    public    = aws_subnet.public[*].id
    private   = aws_subnet.private[*].id
    database  = aws_subnet.database[*].id
  }
}

output "nat_gateway_ip" {
  description = "The public IP address of the NAT Gateway"
  value       = aws_eip.nat.public_ip
} 