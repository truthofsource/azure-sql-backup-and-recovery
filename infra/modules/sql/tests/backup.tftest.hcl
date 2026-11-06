mock_provider "azurerm" {
  mock_resource "azurerm_mssql_server" {
    defaults = { id = "/subscriptions/00000000-0000-4000-8000-000000000001/resourceGroups/rg-example-sql/providers/Microsoft.Sql/servers/sql-example" }
  }
}
variables {
  resource_group_name             = "rg-example-sql"
  resource_group_location         = "centralus"
  location                        = "centralus"
  server_name                     = "sql-example"
  database_name                   = "workforce-example"
  administrator_object_id         = "00000000-0000-4000-8000-000000000003"
  tenant_id                       = "00000000-0000-4000-8000-000000000002"
  tags                            = { environment = "reference" }
  network_resource_group_name     = "rg-example-network"
  network_location                = "centralus"
  virtual_network_id              = "/subscriptions/00000000-0000-4000-8000-000000000001/resourceGroups/rg-example-network/providers/Microsoft.Network/virtualNetworks/vnet-example"
  private_endpoints_subnet_id     = "/subscriptions/00000000-0000-4000-8000-000000000001/resourceGroups/rg-example-network/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/private-endpoints"
  dns_link_name                   = "sql-reference-vnet-link"
  private_endpoint_name           = "pe-example-sql"
  private_service_connection_name = "psc-example-sql"
  private_dns_zone_group_name     = "sql-private-dns"
}
run "production_backup_overrides" {
  command = plan
  variables {
    database_sku_name             = "S0"
    database_max_size_gb          = 10
    database_storage_account_type = "Geo"
    short_term_retention_days     = 14
  }
  assert {
    condition     = azurerm_mssql_database.workforce.sku_name == "S0" && azurerm_mssql_database.workforce.storage_account_type == "Geo" && azurerm_mssql_database.workforce.short_term_retention_policy[0].retention_days == 14
    error_message = "Production must retain explicit S0/Geo/14-day settings."
  }
}
run "nonproduction_defaults_remain_separate" {
  command = plan
  assert {
    condition     = azurerm_mssql_database.workforce.sku_name == "Basic" && azurerm_mssql_database.workforce.storage_account_type == "Local" && azurerm_mssql_database.workforce.short_term_retention_policy[0].retention_days == 7
    error_message = "Shared module defaults must not be mistaken for production."
  }
}
run "private_identity_and_dns_boundary" {
  command = plan
  assert {
    condition     = azurerm_mssql_server.workforce.public_network_access_enabled == false && azurerm_mssql_server.workforce.azuread_administrator[0].azuread_authentication_only && azurerm_mssql_server.workforce.minimum_tls_version == "1.2"
    error_message = "Preserve private SQL, Entra-only administration and TLS."
  }
  assert {
    condition     = azurerm_private_dns_zone.sql.name == "privatelink.database.windows.net" && azurerm_private_dns_zone_virtual_network_link.sql_app_vnet.registration_enabled == false && toset(azurerm_private_endpoint.sql_server.private_service_connection[0].subresource_names) == toset(["sqlServer"])
    error_message = "Preserve SQL private DNS and endpoint subresource."
  }
}
