resource "azurerm_log_analytics_workspace" "log_ws" {
  name                = "acctest-01"
  location            = var.region
  resource_group_name = var.resource_group_name
  sku                 = "Free"
  retention_in_days   = 7
}

resource "azurerm_monitor_diagnostic_setting" "data_factory" {
  count                          = var.use_log_analytics ? 1 : 0
  name                           = "omsdf${var.data_lake_name}"
  target_resource_id             = azurerm_data_factory.df.id
 #log_analytics_workspace_id     = var.log_analytics_workspace_id
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.log_ws.id
  log_analytics_destination_type = "Dedicated"

  metric {
    enabled  = true
    category = "AllMetrics"

    retention_policy {
      enabled = true
      days    = 14
    }
  }

  log {
    enabled  = true
    category = "TriggerRuns"

    retention_policy {
      enabled = true
      days    = 14
    }
  }

  log {
    enabled  = true
    category = "ActivityRuns"

    retention_policy {
      enabled = true
      days    = 14
    }
  }

  log {
    enabled  = true
    category = "PipelineRuns"

    retention_policy {
      enabled = true
      days    = 14
    }
  }
}
