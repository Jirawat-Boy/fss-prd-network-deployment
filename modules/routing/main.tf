data "aws_caller_identity" "current" {}

# Public Route Table - Single table for both AZs

resource "aws_route_table" "network_public_rtb" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.internet_gateway_id
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-rtb-public"
      Type = "Public"
    }
  )
}

resource "aws_route_table_association" "network_public_subnets" {
  count          = length(var.public_subnet_ids)
  subnet_id      = var.public_subnet_ids[count.index]
  route_table_id = aws_route_table.network_public_rtb.id
}

# Private Route Table - Single table for both AZs

resource "aws_route_table" "network_private_rtb" {
  vpc_id = var.vpc_id

  # Add custom routes here if needed (e.g., NAT Gateway, VPN, etc.)
  dynamic "route" {
    for_each = var.private_routes
    content {
      cidr_block                = route.value.cidr_block
      gateway_id                = lookup(route.value, "gateway_id", null)
      nat_gateway_id            = lookup(route.value, "nat_gateway_id", null)
      network_interface_id      = lookup(route.value, "network_interface_id", null)
      transit_gateway_id        = lookup(route.value, "transit_gateway_id", null)
      vpc_endpoint_id           = lookup(route.value, "vpc_endpoint_id", null)
      vpc_peering_connection_id = lookup(route.value, "vpc_peering_connection_id", null)
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-rtb-private"
      Type = "Private"
    }
  )
}

resource "aws_route_table_association" "network_private_subnets" {
  count          = length(var.private_subnet_ids)
  subnet_id      = var.private_subnet_ids[count.index]
  route_table_id = aws_route_table.network_private_rtb.id
}

# Management Route Table - Single table for both AZs

resource "aws_route_table" "network_mgmt_rtb" {
  vpc_id = var.vpc_id

  # Default route to Internet Gateway for management subnet
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.internet_gateway_id
  }

  # Add custom routes here if needed
  dynamic "route" {
    for_each = var.mgmt_routes
    content {
      cidr_block                = route.value.cidr_block
      gateway_id                = lookup(route.value, "gateway_id", null)
      nat_gateway_id            = lookup(route.value, "nat_gateway_id", null)
      network_interface_id      = lookup(route.value, "network_interface_id", null)
      transit_gateway_id        = lookup(route.value, "transit_gateway_id", null)
      vpc_endpoint_id           = lookup(route.value, "vpc_endpoint_id", null)
      vpc_peering_connection_id = lookup(route.value, "vpc_peering_connection_id", null)
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-rtb-mgmt"
      Type = "Management"
    }
  )
}

resource "aws_route_table_association" "network_mgmt_subnets" {
  count          = length(var.mgmt_subnet_ids)
  subnet_id      = var.mgmt_subnet_ids[count.index]
  route_table_id = aws_route_table.network_mgmt_rtb.id
}

# Heartbeat Route Table - Single table for both AZs

resource "aws_route_table" "network_heartbeat_rtb" {
  vpc_id = var.vpc_id

  # Add custom routes here if needed
  dynamic "route" {
    for_each = var.heartbeat_routes
    content {
      cidr_block                = route.value.cidr_block
      gateway_id                = lookup(route.value, "gateway_id", null)
      nat_gateway_id            = lookup(route.value, "nat_gateway_id", null)
      network_interface_id      = lookup(route.value, "network_interface_id", null)
      transit_gateway_id        = lookup(route.value, "transit_gateway_id", null)
      vpc_endpoint_id           = lookup(route.value, "vpc_endpoint_id", null)
      vpc_peering_connection_id = lookup(route.value, "vpc_peering_connection_id", null)
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-rtb-heartbeat"
      Type = "Heartbeat"
    }
  )
}

resource "aws_route_table_association" "network_heartbeat_subnets" {
  count          = length(var.heartbeat_subnet_ids)
  subnet_id      = var.heartbeat_subnet_ids[count.index]
  route_table_id = aws_route_table.network_heartbeat_rtb.id
}

# TGW Route Table - Single table for both AZs

resource "aws_route_table" "network_tgw_subnet_rtb" {
  vpc_id = var.vpc_id
  
  # TGW routes can be managed dynamically
  dynamic "route" {
    for_each = var.tgw_routes
    content {
      cidr_block                = route.value.cidr_block
      gateway_id                = lookup(route.value, "gateway_id", null)
      nat_gateway_id            = lookup(route.value, "nat_gateway_id", null)
      network_interface_id      = lookup(route.value, "network_interface_id", null)
      transit_gateway_id        = lookup(route.value, "transit_gateway_id", null)
      vpc_endpoint_id           = lookup(route.value, "vpc_endpoint_id", null)
      vpc_peering_connection_id = lookup(route.value, "vpc_peering_connection_id", null)
    }
  }
  
  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-rtb-tgw-subnet"
      Type = "TGW"
    }
  )
}

resource "aws_route_table_association" "network_tgw_subnet_rtb_association" {
  count          = length(var.tgw_subnet_ids)
  subnet_id      = var.tgw_subnet_ids[count.index]
  route_table_id = aws_route_table.network_tgw_subnet_rtb.id
}
