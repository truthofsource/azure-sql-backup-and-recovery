variable "subscription_id" { type = string }
variable "tenant_id" { type = string }
variable "administrator_object_id" { type = string }
variable "resource_group_name" { type = string }
variable "server_name" { type = string }
variable "database_name" { type = string }
variable "network_resource_group_name" { type = string }
variable "virtual_network_id" { type = string }
variable "private_endpoints_subnet_id" { type = string }
variable "location" {
  type    = string
  default = "centralus"
}
variable "profile" {
  type    = string
  default = "production"
  validation {
    condition     = contains(["production", "nonproduction"], var.profile)
    error_message = "Choose an explicit production or nonproduction reference profile."
  }
}
variable "production_max_size_gb" {
  type        = number
  default     = 10
  description = "Public reference capacity only; the live platform capacity is not asserted."
}
variable "tags" {
  type    = map(string)
  default = { environment = "reference", owner = "engineering", managed_by = "terraform" }
}
