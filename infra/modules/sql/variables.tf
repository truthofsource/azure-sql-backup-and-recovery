variable "resource_group_location" {
  type = string
}

variable "location" {
  type = string
}

variable "server_name" {
  type = string
}

variable "database_name" {
  type = string
}

variable "database_sku_name" {
  type    = string
  default = "Basic"
}

variable "database_max_size_gb" {
  type    = number
  default = 2
}

variable "database_storage_account_type" {
  type    = string
  default = "Local"
}

variable "short_term_retention_days" {
  type    = number
  default = 7
}

variable "administrator_object_id" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "network_resource_group_name" {
  type = string
}

variable "network_location" {
  type = string
}

variable "virtual_network_id" {
  type = string
}

variable "private_endpoints_subnet_id" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "dns_link_name" {
  type = string
}

variable "private_endpoint_name" {
  type = string
}

variable "private_service_connection_name" {
  type = string
}

variable "private_dns_zone_group_name" {
  type = string
}
