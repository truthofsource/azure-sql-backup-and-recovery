output "server_id" {
  value = azurerm_mssql_server.workforce.id
}

output "server_name" {
  value = azurerm_mssql_server.workforce.name
}

output "database_name" {
  value = azurerm_mssql_database.workforce.name
}

output "private_dns_zone_name" {
  value = azurerm_private_dns_zone.sql.name
}

output "private_endpoint_id" {
  value = azurerm_private_endpoint.sql_server.id
}

output "private_endpoint_name" {
  value = azurerm_private_endpoint.sql_server.name
}
