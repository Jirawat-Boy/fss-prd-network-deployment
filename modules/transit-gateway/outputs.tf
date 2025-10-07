output "transit_gateway_id" {
  description = "ID of the Transit Gateway"
  value       = aws_ec2_transit_gateway.main.id
}

output "transit_gateway_arn" {
  description = "ARN of the Transit Gateway"
  value       = aws_ec2_transit_gateway.main.arn
}

output "transit_gateway_owner_id" {
  description = "Identifier of the AWS account that owns the Transit Gateway"
  value       = aws_ec2_transit_gateway.main.owner_id
}

output "transit_gateway_association_default_route_table_id" {
  description = "Identifier of the default association route table"
  value       = aws_ec2_transit_gateway.main.association_default_route_table_id
}

output "transit_gateway_propagation_default_route_table_id" {
  description = "Identifier of the default propagation route table"
  value       = aws_ec2_transit_gateway.main.propagation_default_route_table_id
}

# VPC attachment outputs moved to transit-gateway-attachment module

output "custom_route_table_id" {
  description = "ID of the custom route table (ips)"
  value       = aws_ec2_transit_gateway_route_table.custom.id
}

output "custom_route_table_spoke_id" {
  description = "ID of the custom route table (spoke)"
  value       = aws_ec2_transit_gateway_route_table.custom2.id
}

output "default_route_table_id" {
  description = "ID of the default route table (null if default association is disabled)"
  value       = var.default_route_table_association == "enable" ? data.aws_ec2_transit_gateway_route_table.default[0].id : null
}

# output "security_group_id" {
#   description = "ID of the Transit Gateway security group"
#   value       = aws_security_group.tgw_sg.id
# }

output "transit_gateway_cidr_blocks" {
  description = "List of associated CIDR blocks"
  value       = aws_ec2_transit_gateway.main.transit_gateway_cidr_blocks
}
