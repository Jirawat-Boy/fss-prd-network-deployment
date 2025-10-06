data "aws_caller_identity" "current" {}

## Network VPC - Resource

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = var.vpc_dns_support
  enable_dns_hostnames = var.vpc_dns_hostnames
  
  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-vpc"
    }
  )
}

## Network Internet Gateway - Resource

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-igw-network"
    }
  )
}

## Network Public Subnets - Resource

resource "aws_subnet" "network_public_subnet" {
  count                   = length(var.network_public_subnet_cidrs)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.network_public_subnet_cidrs[count.index]
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-subnet-public-${substr(element(var.availability_zones, count.index), -1, 1)}"
      Type = "Public"
    }
  )
}

## Network Private Subnets - Resource

resource "aws_subnet" "network_private_subnet" {
  count             = length(var.network_private_subnet_cidrs)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.network_private_subnet_cidrs[count.index]
  availability_zone = element(var.availability_zones, count.index)

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-subnet-private-${substr(element(var.availability_zones, count.index), -1, 1)}"
      Type = "Private"
    }
  )
}

## Network Management Subnets - Resource

resource "aws_subnet" "network_mgmt_subnet" {
  count             = length(var.network_mgmt_subnet_cidrs)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.network_mgmt_subnet_cidrs[count.index]
  availability_zone = element(var.availability_zones, count.index)

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-subnet-mgmt-${substr(element(var.availability_zones, count.index), -1, 1)}"
      Type = "Management"
    }
  )
}

## Network Heartbeat Subnets - Resource

resource "aws_subnet" "network_heartbeat_subnet" {
  count             = length(var.network_heartbeat_subnet_cidrs)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.network_heartbeat_subnet_cidrs[count.index]
  availability_zone = element(var.availability_zones, count.index)

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-subnet-heartbeat-${substr(element(var.availability_zones, count.index), -1, 1)}"
      Type = "Heartbeat"
    }
  )
}

## Network TGW Subnets - Resource

resource "aws_subnet" "network_tgw_subnet" {
  count             = length(var.network_tgw_subnet_cidrs)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.network_tgw_subnet_cidrs[count.index]
  availability_zone = element(var.availability_zones, count.index)

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-subnet-tgw-${substr(element(var.availability_zones, count.index), -1, 1)}"
      Type = "TGW"
    }
  )
}
