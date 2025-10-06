# Transit Gateway Module

This module creates and manages an AWS Transit Gateway with VPC attachments for centralized network connectivity.

## Overview

AWS Transit Gateway is a service that enables you to connect your VPCs and on-premises networks through a central hub. This module provides:

- Transit Gateway with configurable settings
- VPC attachment to the Transit Gateway
- Custom route tables for advanced routing scenarios
- Security groups for Transit Gateway related resources

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│      VPC-A      │    │      VPC-B      │    │   On-Premises   │
│                 │    │                 │    │                 │
└─────────┬───────┘    └─────────┬───────┘    └─────────┬───────┘
          │                      │                      │
          │                      │                      │
    ┌─────▼──────────────────────▼──────────────────────▼─────┐
    │                Transit Gateway                         │
    │                                                        │
    │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
    │  │ Route Table  │  │ Route Table  │  │ Route Table  │  │
    │  │   (Default)  │  │   (Custom)   │  │   (VPN)      │  │
    │  └──────────────┘  └──────────────┘  └──────────────┘  │
    └────────────────────────────────────────────────────────┘
```

## Features

### Core Components
- **Transit Gateway**: Central hub for network connectivity
- **VPC Attachment**: Connects your VPC to the Transit Gateway
- **Route Tables**: Control traffic routing between attachments
- **Security Groups**: Network security for TGW-related resources

### Configuration Options
- **ASN Configuration**: Custom Amazon-side ASN
- **Auto-accept Attachments**: Automatically accept shared attachments
- **DNS Support**: Enable DNS resolution across attached networks
- **VPN ECMP**: Equal Cost Multi-Path for VPN connections
- **Multicast Support**: Optional multicast traffic support

## Usage

### Basic Configuration

```hcl
module "transit_gateway" {
  source = "../../modules/transit-gateway"
  
  project_name   = "my-project"
  vpc_id         = "vpc-12345678"
  tgw_subnet_ids = ["subnet-12345678", "subnet-87654321"]
  
  availability_zones = ["us-west-2a", "us-west-2b"]
  
  tags = {
    Environment = "production"
    Team        = "network"
  }
}
```

### Advanced Configuration

```hcl
module "transit_gateway" {
  source = "../../modules/transit-gateway"
  
  project_name   = "my-project"
  vpc_id         = "vpc-12345678"
  tgw_subnet_ids = ["subnet-12345678", "subnet-87654321"]
  
  # Custom ASN
  amazon_side_asn = 64512
  
  # Advanced settings
  auto_accept_shared_attachments  = "disable"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  
  # Enable multicast
  enable_multicast_support = true
  
  tags = {
    Environment = "production"
    Team        = "network"
  }
}
```

## Subnet Requirements

The Transit Gateway requires dedicated subnets for attachments:

### Subnet Planning
- **Purpose**: Transit Gateway attachments only
- **Size**: Minimum /28 (16 IPs) per AZ
- **Placement**: Typically in private subnets
- **Redundancy**: One subnet per Availability Zone

### Example Subnet Layout
```
VPC CIDR: 10.120.0.0/16

Transit Gateway Subnets:
- AZ-1a: 10.120.5.0/24  (TGW Subnet)
- AZ-1b: 10.120.6.0/24  (TGW Subnet)
```

## Route Tables

### Default Route Table
- Automatically created with Transit Gateway
- Used when `default_route_table_association = "enable"`
- Suitable for simple hub-and-spoke topologies

### Custom Route Table
- Created for advanced routing scenarios
- Allows granular control over traffic flow
- Required for complex network topologies

### Route Propagation
- **Enable**: Routes automatically propagated from attachments
- **Disable**: Manual route management required

## Security Considerations

### Security Groups
- Dedicated security group for TGW-related resources
- Allows traffic from private networks (10.0.0.0/8)
- Restrictive by default, customize as needed

### Network ACLs
- Apply at subnet level for TGW subnets
- Additional layer of security
- Consider cross-AZ traffic patterns

## Cost Optimization

### TGW Costs
- **Hourly charge**: Per Transit Gateway
- **Data processing**: Per GB processed
- **Attachment fees**: Per VPC/VPN attachment

### Best Practices
- Use TGW for multi-VPC connectivity (3+ VPCs)
- Consider VPC peering for simple 2-VPC scenarios
- Monitor data transfer costs

## Monitoring and Logging

### CloudWatch Metrics
- `BytesIn` / `BytesOut`: Data transfer metrics
- `PacketsIn` / `PacketsOut`: Packet count metrics
- `PacketDropCount`: Dropped packets

### VPC Flow Logs
- Enable on TGW subnets for troubleshooting
- Monitor traffic patterns
- Security analysis

## Common Use Cases

### 1. Hub-and-Spoke Topology
```
Multiple VPCs connecting through central TGW
Best for: Centralized services, shared resources
```

### 2. Multi-Region Connectivity
```
TGW peering between regions
Best for: Disaster recovery, global applications
```

### 3. Hybrid Connectivity
```
On-premises to multiple VPCs via VPN/Direct Connect
Best for: Hybrid cloud architectures
```

## Troubleshooting

### Common Issues

1. **Attachment Failed**
   - Check subnet availability
   - Verify IAM permissions
   - Review security group rules

2. **Routing Issues**
   - Verify route table associations
   - Check route propagation settings
   - Review CIDR block conflicts

3. **Connectivity Problems**
   - Check security groups
   - Verify NACLs
   - Review TGW route tables

### Debugging Commands

```bash
# List TGW route tables
aws ec2 describe-transit-gateway-route-tables

# Check TGW attachments
aws ec2 describe-transit-gateway-attachments

# View TGW routes
aws ec2 search-transit-gateway-routes \
  --transit-gateway-route-table-id tgw-rtb-xxx
```

## Module Outputs

| Output | Description |
|--------|-------------|
| `transit_gateway_id` | Transit Gateway ID |
| `transit_gateway_arn` | Transit Gateway ARN |
| `vpc_attachment_id` | VPC attachment ID |
| `custom_route_table_id` | Custom route table ID |
| `default_route_table_id` | Default route table ID |
| `security_group_id` | Security group ID |

## Related Modules

- **VPC Module**: Provides subnets for TGW attachments
- **Firewall Module**: Network security and traffic inspection
- **Routing Module**: Advanced routing configurations

## References

- [AWS Transit Gateway Documentation](https://docs.aws.amazon.com/vpc/latest/tgw/)
- [Transit Gateway Best Practices](https://docs.aws.amazon.com/vpc/latest/tgw/tgw-best-design-practices.html)
- [Transit Gateway Pricing](https://aws.amazon.com/transit-gateway/pricing/)
