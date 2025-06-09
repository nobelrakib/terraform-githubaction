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
