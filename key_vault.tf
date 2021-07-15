resource "azurerm_key_vault" "kvlt" {
  name                       = "datalakekvlt"
  location                   = var.region
  resource_group_name        = var.resource_group_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "create",
      "get",
    ]

    secret_permissions = [
      "set",
      "get",
      "delete",
      "purge",
      "recover"
    ]
  }
}

resource "azurerm_key_vault_access_policy" "df" {
  count              = local.use_kv
  #key_vault_id       = var.key_vault_id
  key_vault_id       = azurerm_key_vault.kvlt.id
  tenant_id          = azurerm_data_factory.df.identity[0].tenant_id
  object_id          = azurerm_data_factory.df.identity[0].principal_id
  secret_permissions = ["list", "get"]
}

resource "azurerm_key_vault_secret" "databricks_token" {
  depends_on   = [var.key_vault_depends_on]
  count        = var.use_key_vault && local.create_databricks_bool ? 1 : 0
  name         = "databricks-access-token"
  value        = databricks_token.token[count.index].token_value
  #key_vault_id       = var.key_vault_id
  key_vault_id       = azurerm_key_vault.kvlt.id
  tags         = local.common_tags
}
/*
resource "azurerm_key_vault_secret" "cosmosdb_connstr" {
  depends_on   = [var.key_vault_depends_on]
  count        = local.use_kv
  name         = "cosmosdb-connection-string"
  value        = "${azurerm_cosmosdb_account.cmdb.connection_strings[0]};Database=${azurerm_cosmosdb_sql_database.cmdb_db.name}"
  #key_vault_id       = var.key_vault_id
  key_vault_id       = azurerm_key_vault.kvlt.id
  tags         = local.common_tags
}
*/
resource "azurerm_key_vault_secret" "storage_key" {
  depends_on   = [var.key_vault_depends_on]
  count        = local.use_kv
  name         = "dl-storage-key"
  value        = azurerm_storage_account.adls.primary_access_key
  #key_vault_id       = var.key_vault_id
  key_vault_id       = azurerm_key_vault.kvlt.id
  tags         = local.common_tags
}
