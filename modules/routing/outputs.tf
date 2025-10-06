output "network_public_route_table_id" {
  description = "ID of public route table"
  value       = aws_route_table.network_public_rtb.id
}

output "network_private_route_table_id" {
  description = "ID of private route table"
  value       = aws_route_table.network_private_rtb.id
}

output "network_tgw_route_table_id" {
  description = "ID of TGW route table"
  value       = aws_route_table.network_tgw_subnet_rtb.id
}

output "network_mgmt_route_table_id" {
  description = "ID of management route table"
  value       = aws_route_table.network_mgmt_rtb.id
}

output "network_heartbeat_route_table_id" {
  description = "ID of heartbeat route table"
  value       = aws_route_table.network_heartbeat_rtb.id
}

# Route table associations
output "public_route_table_associations" {
  description = "Public subnet route table associations"
  value       = aws_route_table_association.network_public_subnets[*].id
}

output "private_route_table_associations" {
  description = "Private subnet route table associations"
  value       = aws_route_table_association.network_private_subnets[*].id
}

output "tgw_route_table_associations" {
  description = "TGW subnet route table associations"
  value       = aws_route_table_association.network_tgw_subnet_rtb_association[*].id
}

output "mgmt_route_table_associations" {
  description = "Management subnet route table associations"
  value       = aws_route_table_association.network_mgmt_subnets[*].id
}

output "heartbeat_route_table_associations" {
  description = "Heartbeat subnet route table associations"
  value       = aws_route_table_association.network_heartbeat_subnets[*].id
}

output "whoami" {
  value = data.aws_caller_identity.current.arn
}
