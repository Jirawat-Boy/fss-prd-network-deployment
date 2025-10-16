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

# IAM role for FortiGate operations
resource "aws_iam_role" "fortigate_role" {
  name = "${var.project_name}-fortigate-role"

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
    Name = "${var.project_name}-fortigate-role"
    Purpose = "FortiGate Operations"
  })
}

# IAM policy for FortiGate operations
resource "aws_iam_role_policy" "fortigate_policy" {
  name = "${var.project_name}-fortigate-policy"
  role = aws_iam_role.fortigate_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
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

# IAM instance profile for FortiGate instance
resource "aws_iam_instance_profile" "fortigate_profile" {
  name = "${var.project_name}-fortigate-profile"
  role = aws_iam_role.fortigate_role.name

  tags = merge(var.tags, {
    Name = "${var.project_name}-fortigate-profile"
    Purpose = "FortiGate Operations"
  })
}

# Generate RSA key pair for FortiGate instance
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

# Network Interfaces

# FortiGate Management Interface
resource "aws_network_interface" "fortigate_mgmt" {
  subnet_id         = var.mgmt_subnet_ids[0]
  private_ips       = [var.mgmt_private_ip]
  security_groups   = [aws_security_group.fortigate_mgmt_sg.id]
  source_dest_check = false
  description       = "FortiGate Management Interface"

  tags = merge(var.tags, {
    Name = "${var.project_name}-fortigate-mgmt-eni"
    Type = "Management"
  })
}

# FortiGate Public Interface
resource "aws_network_interface" "fortigate_public" {
  subnet_id         = var.public_subnet_ids[0]
  private_ips       = [var.public_private_ip]
  security_groups   = [aws_security_group.fortigate_public_sg.id]
  source_dest_check = false
  description       = "FortiGate Public Interface"

  tags = merge(var.tags, {
    Name = "${var.project_name}-fortigate-public-eni"
    Type = "Public"
  })
}

# FortiGate Private Interface
resource "aws_network_interface" "fortigate_private" {
  subnet_id         = var.private_subnet_ids[0]
  private_ips       = [var.private_private_ip]
  security_groups   = [aws_security_group.fortigate_private_sg.id]
  source_dest_check = false
  description       = "FortiGate Private Interface"

  tags = merge(var.tags, {
    Name = "${var.project_name}-fortigate-private-eni"
    Type = "Private"
  })
}

# Elastic IP for Management
resource "aws_eip" "fortigate_mgmt_eip" {
  domain            = "vpc"
  network_interface = aws_network_interface.fortigate_mgmt.id

  tags = merge(var.tags, {
    Name = "${var.project_name}-fortigate-mgmt-eip"
    Type = "Management"
  })
}

# Elastic IP for Public Interface
resource "aws_eip" "fortigate_public_eip" {
  domain            = "vpc"
  network_interface = aws_network_interface.fortigate_public.id

  tags = merge(var.tags, {
    Name = "${var.project_name}-fortigate-public-eip"
    Type = "Public"
  })
}

# FortiGate Instance
resource "aws_instance" "fortigate" {
  ami                  = local.fortigate_ami_id
  instance_type        = var.fortigate_instance_type
  key_name             = var.create_key_pair ? aws_key_pair.fortigate_key_pair[0].key_name : var.key_pair_name
  iam_instance_profile = aws_iam_instance_profile.fortigate_profile.name

  # Attach network interfaces
  network_interface {
    network_interface_id = aws_network_interface.fortigate_mgmt.id
    device_index         = 0
  }

  network_interface {
    network_interface_id = aws_network_interface.fortigate_public.id
    device_index         = 1
  }

  network_interface {
    network_interface_id = aws_network_interface.fortigate_private.id
    device_index         = 2
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-fortigate"
    Type = "Firewall"
    "fgt-license-type" = var.fortigate_license_type
  })
}