variable "tags" {
  type = map(any)
  default = {}
}

variable "project_name" {
  description = "Name for resources"
  type        = string
  default     = "project-default"
}

variable "vpc_id" {
  description = "The VPC ID where route tables will be created"
  type        = string
}

variable "internet_gateway_id" {
  description = "The Internet Gateway ID for public routing"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

# Subnet IDs from VPC module
variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "tgw_subnet_ids" {
  description = "List of TGW subnet IDs"
  type        = list(string)
}

variable "mgmt_subnet_ids" {
  description = "List of management subnet IDs"
  type        = list(string)
}

variable "heartbeat_subnet_ids" {
  description = "List of heartbeat subnet IDs"
  type        = list(string)
}

# Custom route definitions
variable "private_routes" {
  description = "List of routes for private subnets"
  type = list(object({
    cidr_block                = string
    gateway_id                = optional(string)
    nat_gateway_id            = optional(string)
    network_interface_id      = optional(string)
    transit_gateway_id        = optional(string)
    vpc_endpoint_id           = optional(string)
    vpc_peering_connection_id = optional(string)
  }))
  default = []
}

variable "mgmt_routes" {
  description = "List of routes for management subnets"
  type = list(object({
    cidr_block                = string
    gateway_id                = optional(string)
    nat_gateway_id            = optional(string)
    network_interface_id      = optional(string)
    transit_gateway_id        = optional(string)
    vpc_endpoint_id           = optional(string)
    vpc_peering_connection_id = optional(string)
  }))
  default = []
}

variable "heartbeat_routes" {
  description = "List of routes for heartbeat subnets"
  type = list(object({
    cidr_block                = string
    gateway_id                = optional(string)
    nat_gateway_id            = optional(string)
    network_interface_id      = optional(string)
    transit_gateway_id        = optional(string)
    vpc_endpoint_id           = optional(string)
    vpc_peering_connection_id = optional(string)
  }))
  default = []
}

variable "tgw_routes" {
  description = "List of routes for TGW subnets"
  type = list(object({
    cidr_block                = string
    gateway_id                = optional(string)
    nat_gateway_id            = optional(string)
    network_interface_id      = optional(string)
    transit_gateway_id        = optional(string)
    vpc_endpoint_id           = optional(string)
    vpc_peering_connection_id = optional(string)
  }))
  default = []
}
