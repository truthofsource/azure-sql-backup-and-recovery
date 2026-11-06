resource "azurerm_resource_group" "data_nonproduction" {
  name     = var.resource_group_name
  location = var.resource_group_location

  tags = var.tags
}

resource "azurerm_mssql_server" "workforce" {
  name                = var.server_name
  resource_group_name = azurerm_resource_group.data_nonproduction.name
  location            = var.location

  version                       = "12.0"
  minimum_tls_version           = "1.2"
  public_network_access_enabled = false

  azuread_administrator {
    login_username              = "grp-example-platform-owners"
    object_id                   = var.administrator_object_id
    tenant_id                   = var.tenant_id
    azuread_authentication_only = true
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

resource "azurerm_mssql_database" "workforce" {
  name      = var.database_name
  server_id = azurerm_mssql_server.workforce.id

  sku_name             = var.database_sku_name
  max_size_gb          = var.database_max_size_gb
  storage_account_type = var.database_storage_account_type

  zone_redundant = false

  short_term_retention_policy {
    retention_days = var.short_term_retention_days
  }

  tags = var.tags

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_private_dns_zone" "sql" {
  name                = "privatelink.database.windows.net"
  resource_group_name = var.network_resource_group_name

  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "sql_app_vnet" {
  name                  = var.dns_link_name
  resource_group_name   = var.network_resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.sql.name
  virtual_network_id    = var.virtual_network_id
  registration_enabled  = false

  tags = var.tags
}

resource "azurerm_private_endpoint" "sql_server" {
  name                = var.private_endpoint_name
  resource_group_name = var.network_resource_group_name
  location            = var.network_location
  subnet_id           = var.private_endpoints_subnet_id

  private_service_connection {
    name                           = var.private_service_connection_name
    private_connection_resource_id = azurerm_mssql_server.workforce.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = var.private_dns_zone_group_name
    private_dns_zone_ids = [azurerm_private_dns_zone.sql.id]
  }

  tags = var.tags
}
