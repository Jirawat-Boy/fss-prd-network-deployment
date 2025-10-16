locals {
  # Project configuration
  project_name = "fss-prd"
  
  availability_zones = [
    "ap-southeast-7a",
    "ap-southeast-7b"
  ]
  
  # TGW routes - Route to other networks via Transit Gateway
  tgw_routes = [
    {
      cidr_block         = "10.23.0.0/16"
      transit_gateway_id = "tgw-053d8a9262e7e2c74"
    }
  ]
  
  # Private routes configuration - Route to other networks via Transit Gateway
  private_routes = [
    {
      cidr_block         = "10.23.0.0/16"
      transit_gateway_id = "tgw-053d8a9262e7e2c74"
    }
  ]
  
  mgmt_routes      = []
  heartbeat_routes = []
}

terraform {
  source = "../../../../modules/routing"
}

include "root" {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../vpc"
  
  mock_outputs = {
    vpc_id                         = "vpc-mock"
    internet_gateway_id           = "igw-mock"
    network_public_subnet_ids     = ["subnet-mock1", "subnet-mock2"]
    network_private_subnet_ids    = ["subnet-mock3", "subnet-mock4"]
    network_tgw_subnet_ids        = ["subnet-mock5", "subnet-mock6"]
    network_mgmt_subnet_ids       = ["subnet-mock7", "subnet-mock8"]
    network_heartbeat_subnet_ids  = ["subnet-mock9", "subnet-mock10"]
  }
}

inputs = {
  # Basic configuration
  project_name       = local.project_name
  availability_zones = local.availability_zones
  
  # VPC information from dependency
  vpc_id              = dependency.vpc.outputs.vpc_id
  internet_gateway_id = dependency.vpc.outputs.internet_gateway_id
  
  # Subnet IDs from VPC module
  public_subnet_ids    = dependency.vpc.outputs.network_public_subnet_ids
  private_subnet_ids   = dependency.vpc.outputs.network_private_subnet_ids
  tgw_subnet_ids       = dependency.vpc.outputs.network_tgw_subnet_ids
  mgmt_subnet_ids      = dependency.vpc.outputs.network_mgmt_subnet_ids
  heartbeat_subnet_ids = dependency.vpc.outputs.network_heartbeat_subnet_ids
  
  # Custom routes
  private_routes   = local.private_routes
  mgmt_routes      = local.mgmt_routes
  tgw_routes       = local.tgw_routes
  heartbeat_routes = local.heartbeat_routes
  
  # Tags
  tags = {
    Project     = local.project_name
    Environment = "PRD"
    Created-by  = "TrueIDC"
    Created-at  = formatdate("DD-MMM-YY", timestamp())
    ManagedBy   = "terraform"
  }

}
