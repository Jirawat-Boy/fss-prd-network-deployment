data "aws_caller_identity" "current" {}

# FortiGate AMI Data Source
data "aws_ami" "fortigate" {
  count       = var.fortigate_ami_id == "" ? 1 : 0
  most_recent = true
  owners      = ["679593333241"] # Fortinet AWS Account ID

  filter {
    name   = "name"
    values = ["FortiGate-VM64-AWSONDEMAND*${var.fortigate_version}*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# Local value to determine which AMI to use
locals {
  fortigate_ami_id = var.fortigate_ami_id != "" ? var.fortigate_ami_id : data.aws_ami.fortigate[0].id
}

# IAM role for FortiGate HA operations
resource "aws_iam_role" "fortigate_ha_role" {
  name = "${var.project_name}-fortigate-ha-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.project_name}-fortigate-ha-role"
    Purpose = "FortiGate HA Operations"
  })
}

# IAM policy for FortiGate HA operations
resource "aws_iam_role_policy" "fortigate_ha_policy" {
  name = "${var.project_name}-fortigate-ha-policy"
  role = aws_iam_role.fortigate_ha_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeRouteTables",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets",
          "ec2:DescribeAddresses",
          "ec2:ReplaceRoute",
          "ec2:CreateRoute",
          "ec2:DeleteRoute",
          "ec2:AssociateAddress",
          "ec2:DisassociateAddress",
          "ec2:ModifyNetworkInterfaceAttribute",
          "ec2:DescribeTags",
          "ec2:CreateTags",
          "ec2:AssignPrivateIpAddresses",
          "ec2:UnassignPrivateIpAddresses"
        ]
        Resource = "*"
      }
    ]
  })
}

# IAM instance profile for FortiGate instances
resource "aws_iam_instance_profile" "fortigate_ha_profile" {
  name = "${var.project_name}-fortigate-ha-profile"
  role = aws_iam_role.fortigate_ha_role.name

  tags = merge(var.tags, {
    Name = "${var.project_name}-fortigate-ha-profile"
    Purpose = "FortiGate HA Operations"
  })
}

# Generate RSA key pair for FortiGate instances
resource "tls_private_key" "fortigate_key" {
  count     = var.create_key_pair && var.public_key_content == "" ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Create AWS Key Pair
resource "aws_key_pair" "fortigate_key_pair" {
  count      = var.create_key_pair ? 1 : 0
  key_name   = var.key_pair_name
  public_key = var.public_key_content != "" ? var.public_key_content : tls_private_key.fortigate_key[0].public_key_openssh

  tags = merge(var.tags, {
    Name    = var.key_pair_name
    Purpose = "FortiGate SSH Access"
  })
}

# Local file to store private key (for reference only)
resource "local_file" "private_key" {
  count           = var.create_key_pair && var.public_key_content == "" ? 1 : 0
  content         = tls_private_key.fortigate_key[0].private_key_pem
  filename        = "${path.root}/${var.key_pair_name}.pem"
  file_permission = "0600"
}

# Security Groups

# Management Security Group
resource "aws_security_group" "fortigate_mgmt_sg" {
  name        = "${var.project_name}-fortigate-mgmt-sg"
  vpc_id      = var.vpc_id
  description = "Security group for FortiGate management interface"

  # HTTPS for management
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.admin_cidr_blocks
    description = "HTTPS management access"
  }

  # SSH for management
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.admin_cidr_blocks
    description = "SSH management access"
  }

  # SNMP (optional)
  ingress {
    from_port   = 161
    to_port     = 161
    protocol    = "udp"
    cidr_blocks = var.admin_cidr_blocks
    description = "SNMP monitoring"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-fortigate-mgmt-sg"
    Type = "Management"
  })
}

# Public/External Security Group
resource "aws_security_group" "fortigate_public_sg" {
  name        = "${var.project_name}-fortigate-public-sg"
  vpc_id      = var.vpc_id
  description = "Security group for FortiGate public/external interface"

  # Allow all inbound traffic (FortiGate will filter)
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All inbound traffic (filtered by FortiGate)"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-fortigate-public-sg"
    Type = "Public"
  })
}

# Private/Internal Security Group
resource "aws_security_group" "fortigate_private_sg" {
  name        = "${var.project_name}-fortigate-private-sg"
  vpc_id      = var.vpc_id
  description = "Security group for FortiGate private/internal interface"

  # Allow all traffic from VPC
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/8"]
    description = "All traffic from private networks"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-fortigate-private-sg"
    Type = "Private"
  })
}

# Heartbeat Security Group
resource "aws_security_group" "fortigate_heartbeat_sg" {
  name        = "${var.project_name}-fortigate-heartbeat-sg"
  vpc_id      = var.vpc_id
  description = "Security group for FortiGate HA heartbeat interface"

  # HA heartbeat traffic
  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    self      = true
    description = "HA heartbeat TCP"
  }

  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "udp"
    self      = true
    description = "HA heartbeat UDP"
  }

  egress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    self      = true
    description = "HA heartbeat TCP outbound"
  }

  egress {
    from_port = 0
    to_port   = 65535
    protocol  = "udp"
    self      = true
    description = "HA heartbeat UDP outbound"
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-fortigate-heartbeat-sg"
    Type = "Heartbeat"
  })
}

# Network Interfaces

# Primary FortiGate Network Interfaces
resource "aws_network_interface" "fortigate_primary_mgmt" {
  subnet_id         = var.mgmt_subnet_ids[0]
  private_ips       = ["10.22.7.254"]
  security_groups   = [aws_security_group.fortigate_mgmt_sg.id]
  source_dest_check = false
  description       = "FortiGate Primary Management Interface"

  tags = merge(var.tags, {
    Name = "${var.project_name}-fortigate-primary-mgmt-eni"
    Type = "Management"
    Instance = "Primary"
  })
}

resource "aws_network_interface" "fortigate_primary_public" {
  subnet_id         = var.public_subnet_ids[0]
  private_ips       = ["10.22.1.254"]
  security_groups   = [aws_security_group.fortigate_public_sg.id]
  source_dest_check = false
  description       = "FortiGate Primary Public Interface"

  tags = merge(var.tags, {
    Name = "${var.project_name}-fortigate-primary-public-eni"
    Type = "Public"
    Instance = "Primary"
  })
}

resource "aws_network_interface" "fortigate_primary_private" {
  subnet_id         = var.private_subnet_ids[0]
  private_ips       = ["10.22.3.254"]
  security_groups   = [aws_security_group.fortigate_private_sg.id]
  source_dest_check = false
  description       = "FortiGate Primary Private Interface"

  tags = merge(var.tags, {
    Name = "${var.project_name}-fortigate-primary-private-eni"
    Type = "Private"
    Instance = "Primary"
  })
}

resource "aws_network_interface" "fortigate_primary_heartbeat" {
  count             = var.enable_ha ? 1 : 0
  subnet_id         = var.heartbeat_subnet_ids[0]
  private_ips       = ["10.22.5.254"]
  security_groups   = [aws_security_group.fortigate_heartbeat_sg.id]
  source_dest_check = false
  description       = "FortiGate Primary Heartbeat Interface"

  tags = merge(var.tags, {
    Name = "${var.project_name}-fortigate-primary-heartbeat-eni"
    Type = "Heartbeat"
    Instance = "Primary"
  })
}

# Secondary FortiGate Network Interfaces (HA)
resource "aws_network_interface" "fortigate_secondary_mgmt" {
  count             = var.enable_ha ? 1 : 0
  subnet_id         = var.mgmt_subnet_ids[1]
  private_ips       = ["10.22.8.254"]
  security_groups   = [aws_security_group.fortigate_mgmt_sg.id]
  source_dest_check = false
  description       = "FortiGate Secondary Management Interface"

  tags = merge(var.tags, {
    Name = "${var.project_name}-fortigate-secondary-mgmt-eni"
    Type = "Management"
    Instance = "Secondary"
  })
}

resource "aws_network_interface" "fortigate_secondary_public" {
  count             = var.enable_ha ? 1 : 0
  subnet_id         = var.public_subnet_ids[1]
  private_ips       = ["10.22.2.254"]
  security_groups   = [aws_security_group.fortigate_public_sg.id]
  source_dest_check = false
  description       = "FortiGate Secondary Public Interface"

  tags = merge(var.tags, {
    Name = "${var.project_name}-fortigate-secondary-public-eni"
    Type = "Public"
    Instance = "Secondary"
  })
}

resource "aws_network_interface" "fortigate_secondary_private" {
  count             = var.enable_ha ? 1 : 0
  subnet_id         = var.private_subnet_ids[1]
  private_ips       = ["10.22.4.254"]
  security_groups   = [aws_security_group.fortigate_private_sg.id]
  source_dest_check = false
  description       = "FortiGate Secondary Private Interface"

  tags = merge(var.tags, {
    Name = "${var.project_name}-fortigate-secondary-private-eni"
    Type = "Private"
    Instance = "Secondary"
  })
}

resource "aws_network_interface" "fortigate_secondary_heartbeat" {
  count             = var.enable_ha ? 1 : 0
  subnet_id         = var.heartbeat_subnet_ids[1]
  private_ips       = ["10.22.6.254"]
  security_groups   = [aws_security_group.fortigate_heartbeat_sg.id]
  source_dest_check = false
  description       = "FortiGate Secondary Heartbeat Interface"

  tags = merge(var.tags, {
    Name = "${var.project_name}-fortigate-secondary-heartbeat-eni"
    Type = "Heartbeat"
    Instance = "Secondary"
  })
}

# Elastic IPs for Management
resource "aws_eip" "fortigate_primary_mgmt_eip" {
  domain            = "vpc"
  network_interface = aws_network_interface.fortigate_primary_mgmt.id

  tags = merge(var.tags, {
    Name = "${var.project_name}-fortigate-primary-mgmt-eip"
    Type = "Management"
    Instance = "Primary"
  })
}

resource "aws_eip" "fortigate_secondary_mgmt_eip" {
  count             = var.enable_ha ? 1 : 0
  domain            = "vpc"
  network_interface = aws_network_interface.fortigate_secondary_mgmt[0].id

  tags = merge(var.tags, {
    Name = "${var.project_name}-fortigate-secondary-mgmt-eip"
    Type = "Management"
    Instance = "Secondary"
  })
}

# Elastic IP for Primary Public Interface Only
resource "aws_eip" "fortigate_primary_public_eip" {
  domain            = "vpc"
  network_interface = aws_network_interface.fortigate_primary_public.id

  tags = merge(var.tags, {
    Name = "${var.project_name}-fortigate-primary-public-eip"
    Type = "Public"
    Instance = "Primary"
  })
}

# Elastic IP for Secondary Public Interface Only (HA
# resource "aws_eip" "fortigate_secondary_public_eip" {
#   count             = var.enable_ha ? 1 : 0
#   domain            = "vpc"
#   network_interface = aws_network_interface.fortigate_secondary_public[0].id

#   tags = merge(var.tags, {
#     Name = "${var.project_name}-fortigate-secondary-public-eip"
#     Type = "Public"
#     Instance = "Secondary"
#   })
# }

# User Data for FortiGate Configuration
# locals {
#   fortigate_primary_userdata = base64encode(templatefile("${path.module}/templates/fortigate_primary_config.tpl", {
#     admin_username    = var.fortigate_admin_username
#     peer_heartbeat_ip = var.enable_ha ? "10.22.6.254" : ""
#     enable_ha        = var.enable_ha
#     vpc_id           = var.vpc_id
#   }))
#
#   fortigate_secondary_userdata = var.enable_ha ? base64encode(templatefile("${path.module}/templates/fortigate_secondary_config.tpl", {
#     admin_username    = var.fortigate_admin_username
#     peer_heartbeat_ip = "10.22.5.254"
#     vpc_id           = var.vpc_id
#   })) : ""
# }

# FortiGate Instances
resource "aws_instance" "fortigate_primary" {
  ami                  = local.fortigate_ami_id
  instance_type        = var.fortigate_instance_type
  key_name             = var.create_key_pair ? aws_key_pair.fortigate_key_pair[0].key_name : var.key_pair_name
  iam_instance_profile = aws_iam_instance_profile.fortigate_ha_profile.name
  # user_data            = local.fortigate_primary_userdata

  # Attach network interfaces
  network_interface {
    network_interface_id = aws_network_interface.fortigate_primary_mgmt.id
    device_index         = 0
  }

  network_interface {
    network_interface_id = aws_network_interface.fortigate_primary_public.id
    device_index         = 1
  }

  network_interface {
    network_interface_id = aws_network_interface.fortigate_primary_private.id
    device_index         = 2
  }

  dynamic "network_interface" {
    for_each = var.enable_ha ? [1] : []
    content {
      network_interface_id = aws_network_interface.fortigate_primary_heartbeat[0].id
      device_index         = 3
    }
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-fortigate-primary"
    Type = "Firewall"
    Instance = "Primary"
    "fgt-ha-group-id" = "FGT-HA"
    "fgt-ha-member" = "1"
    "fgt-ha-role" = "primary"
    "fgt-auto-scale" = "enable"
    "fgt-license-type" = var.fortigate_license_type
  })
}

resource "aws_instance" "fortigate_secondary" {
  count                = var.enable_ha ? 1 : 0
  ami                  = local.fortigate_ami_id
  instance_type        = var.fortigate_instance_type
  key_name             = var.create_key_pair ? aws_key_pair.fortigate_key_pair[0].key_name : var.key_pair_name
  iam_instance_profile = aws_iam_instance_profile.fortigate_ha_profile.name
  # user_data            = local.fortigate_secondary_userdata

  # Attach network interfaces
  network_interface {
    network_interface_id = aws_network_interface.fortigate_secondary_mgmt[0].id
    device_index         = 0
  }

  network_interface {
    network_interface_id = aws_network_interface.fortigate_secondary_public[0].id
    device_index         = 1
  }

  network_interface {
    network_interface_id = aws_network_interface.fortigate_secondary_private[0].id
    device_index         = 2
  }

  network_interface {
    network_interface_id = aws_network_interface.fortigate_secondary_heartbeat[0].id
    device_index         = 3
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-fortigate-secondary"
    Type = "Firewall"
    Instance = "Secondary"
    "fgt-ha-group-id" = "FGT-HA"
    "fgt-ha-member" = "2"
    "fgt-ha-role" = "secondary"
    "fgt-auto-scale" = "enable"
    "fgt-license-type" = var.fortigate_license_type
  })
}
