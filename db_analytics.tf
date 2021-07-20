resource "azurerm_mssql_server" "db_srv" {
  count                        = local.create_db_count
  name                         = "dwsrv${var.data_lake_name}"
  location                     = var.region
  resource_group_name          = var.resource_group_name
  tags                         = local.common_tags
  version                      = var.mssql_version
  administrator_login          = var.sql_server_admin_username
  administrator_login_password = length(azurerm_key_vault_secret.sql_key) > 0 ? azurerm_key_vault_secret.sql_key[0].value : var.sql_server_admin_password
  minimum_tls_version          = var.ssl_minimal_tls_version_enforced
}

resource "azurerm_mssql_database" "db" {
  count                            = local.create_db_count
  name                             = "datawarehouse"
  server_id                        = azurerm_mssql_server.db_srv[count.index].id
  tags                             = local.common_tags
  sku_name                         = "S0"
}

resource "azurerm_mssql_firewall_rule" "allow_azure_services" {
  count               = local.create_db_count
  name                = "allow-azure-services"
  server_id           = azurerm_mssql_server.db_srv[count.index].id
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}