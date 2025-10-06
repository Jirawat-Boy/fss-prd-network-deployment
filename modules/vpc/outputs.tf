output "vpc_id" {
  description = "The VPC ID"
  value       = aws_vpc.vpc.id
}

output "vpc_cidr_block" {
  description = "The VPC CIDR block"
  value       = aws_vpc.vpc.cidr_block
}

output "internet_gateway_id" {
  description = "The Internet Gateway ID"
  value       = aws_internet_gateway.igw.id
}

# Public Subnet Outputs
output "network_public_subnet_ids" {
  description = "IDs of network public subnets"
  value       = aws_subnet.network_public_subnet[*].id
}

output "network_public_subnet_cidrs" {
  description = "CIDR blocks of public subnets"
  value       = aws_subnet.network_public_subnet[*].cidr_block
}

# Private Subnet Outputs
output "network_private_subnet_ids" {
  description = "IDs of network private subnets"
  value       = aws_subnet.network_private_subnet[*].id
}

output "network_private_subnet_cidrs" {
  description = "CIDR blocks of private subnets"
  value       = aws_subnet.network_private_subnet[*].cidr_block
}

# TGW Subnet Outputs
output "network_tgw_subnet_ids" {
  description = "IDs of TGW subnets"
  value       = aws_subnet.network_tgw_subnet[*].id
}

output "network_tgw_subnet_cidrs" {
  description = "CIDR blocks of TGW subnets"
  value       = aws_subnet.network_tgw_subnet[*].cidr_block
}

# Management Subnet Outputs
output "network_mgmt_subnet_ids" {
  description = "IDs of network management subnets"
  value       = aws_subnet.network_mgmt_subnet[*].id
}

output "network_mgmt_subnet_cidrs" {
  description = "CIDR blocks of management subnets"
  value       = aws_subnet.network_mgmt_subnet[*].cidr_block
}

# Heartbeat Subnet Outputs
output "network_heartbeat_subnet_ids" {
  description = "IDs of network heartbeat subnets"
  value       = aws_subnet.network_heartbeat_subnet[*].id
}

output "network_heartbeat_subnet_cidrs" {
  description = "CIDR blocks of heartbeat subnets"
  value       = aws_subnet.network_heartbeat_subnet[*].cidr_block
}

# Additional Outputs
output "availability_zones" {
  description = "List of availability zones used"
  value       = var.availability_zones
}

output "whoami" {
  value = data.aws_caller_identity.current.arn
}
