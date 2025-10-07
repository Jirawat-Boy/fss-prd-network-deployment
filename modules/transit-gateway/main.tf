# Transit Gateway
resource "aws_ec2_transit_gateway" "main" {
  description = "Transit Gateway for ${var.project_name}"
  
  # ASN Configuration
  amazon_side_asn = var.amazon_side_asn
  
  # Attachment Settings
  auto_accept_shared_attachments  = var.auto_accept_shared_attachments
  default_route_table_association = var.default_route_table_association
  default_route_table_propagation = var.default_route_table_propagation
  
  # DNS and VPN Settings
  dns_support                     = var.dns_support
  vpn_ecmp_support               = var.vpn_ecmp_support
  
  # Multicast Support
  multicast_support = var.enable_multicast_support ? "enable" : "disable"

  tags = merge(var.tags, {
    Name = "${var.project_name}-network-transit-gateway"
    Type = "TransitGateway"
  })
}

# VPC Attachment is now handled by a separate module: transit-gateway-attachment

# Default Route Table (only if default association is enabled)
data "aws_ec2_transit_gateway_route_table" "default" {
  count      = var.default_route_table_association == "enable" ? 1 : 0
  depends_on = [aws_ec2_transit_gateway.main]
  
  filter {
    name   = "default-association-route-table"
    values = ["true"]
  }
  
  filter {
    name   = "transit-gateway-id"
    values = [aws_ec2_transit_gateway.main.id]
  }
}

# Custom Route Table (for manual routing control)
resource "aws_ec2_transit_gateway_route_table" "custom" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id

  tags = merge(var.tags, {
    Name = "${var.project_name}-tgw-rtb-ips"
    Type = "RouteTable"
  })
}

# Custom Route Table (for manual routing control)
resource "aws_ec2_transit_gateway_route_table" "custom2" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id

  tags = merge(var.tags, {
    Name = "${var.project_name}-tgw-rtb-spoke"
    Type = "RouteTable"
  })
}

# Route Table Association (associate VPC attachment with custom route table)
# Commented out to disable automatic spoke routing
# resource "aws_ec2_transit_gateway_route_table_association" "vpc_association" {
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.main.id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.custom.id
# }

# Route Table Propagation (propagate routes from VPC to route table)
# Commented out to disable automatic spoke routing
# resource "aws_ec2_transit_gateway_route_table_propagation" "vpc_propagation" {
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.main.id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.custom.id
# }

# Security Group for Transit Gateway (if needed for endpoints)
# resource "aws_security_group" "tgw_sg" {
#   name        = "${var.project_name}-tgw-sg"
#   description = "Security group for Transit Gateway related resources"
#   vpc_id      = var.vpc_id

#   # Allow all traffic within VPC
#   ingress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["10.0.0.0/8"]
#     description = "Allow all traffic from private networks"
#   }

#   # Allow all outbound traffic
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#     description = "Allow all outbound traffic"
#   }

#   tags = merge(var.tags, {
#     Name = "${var.project_name}-tgw-sg"
#     Type = "SecurityGroup"
#   })
# }
