locals {
  profiles = {
    production    = { sku = "S0", redundancy = "Geo", retention = 14, capacity = var.production_max_size_gb }
    nonproduction = { sku = "Basic", redundancy = "Local", retention = 7, capacity = 2 }
  }
  selected = local.profiles[var.profile]
}
module "sql" {
  source                          = "./modules/sql"
  resource_group_name             = var.resource_group_name
  resource_group_location         = var.location
  location                        = var.location
  server_name                     = var.server_name
  database_name                   = var.database_name
  database_sku_name               = local.selected.sku
  database_max_size_gb            = local.selected.capacity
  database_storage_account_type   = local.selected.redundancy
  short_term_retention_days       = local.selected.retention
  administrator_object_id         = var.administrator_object_id
  tenant_id                       = var.tenant_id
  tags                            = var.tags
  network_resource_group_name     = var.network_resource_group_name
  network_location                = var.location
  virtual_network_id              = var.virtual_network_id
  private_endpoints_subnet_id     = var.private_endpoints_subnet_id
  dns_link_name                   = "sql-reference-vnet-link"
  private_endpoint_name           = "pe-example-sql"
  private_service_connection_name = "psc-example-sql"
  private_dns_zone_group_name     = "sql-private-dns"
}
output "backup_profile" { value = local.selected }
