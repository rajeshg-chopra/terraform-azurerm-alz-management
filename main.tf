
resource "azurerm_resource_group" "management" {
  count = var.deploy_resource_group ? 1 : 0

  location = var.location
  name     = var.resource_group_name
  tags = merge(var.tags, (/*<box>*/ (var.tracing_tags_enabled ? { for k, v in /*</box>*/ {
    avm_git_commit           = "ba28d2019d124ec455bed690e553fe9c7e4e2780"
    avm_git_file             = "main.tf"
    avm_git_last_modified_at = "2023-05-15 11:25:58"
    avm_git_org              = "Azure"
    avm_git_repo             = "terraform-azurerm-alz-management"
    avm_yor_name             = "management"
    avm_yor_trace            = "4573afcf-fbd1-47c5-8e92-062dbd7c416f"
  } /*<box>*/ : replace(k, "avm_", var.tracing_tags_prefix) => v } : {}) /*</box>*/))
}

resource "azurerm_log_analytics_workspace" "management" {
  location                           = var.location
  name                               = var.log_analytics_workspace_name
  resource_group_name                = var.resource_group_name
  allow_resource_only_permissions    = var.log_analytics_workspace_allow_resource_only_permissions
  cmk_for_query_forced               = var.log_analytics_workspace_cmk_for_query_forced
  daily_quota_gb                     = var.log_analytics_workspace_daily_quota_gb
  internet_ingestion_enabled         = var.log_analytics_workspace_internet_ingestion_enabled
  internet_query_enabled             = var.log_analytics_workspace_internet_query_enabled
  reservation_capacity_in_gb_per_day = var.log_analytics_workspace_reservation_capacity_in_gb_per_day
  retention_in_days                  = var.log_analytics_workspace_retention_in_days
  sku                                = var.log_analytics_workspace_sku
  tags = merge(var.tags, (/*<box>*/ (var.tracing_tags_enabled ? { for k, v in /*</box>*/ {
    avm_git_commit           = "ba28d2019d124ec455bed690e553fe9c7e4e2780"
    avm_git_file             = "main.tf"
    avm_git_last_modified_at = "2023-05-15 11:25:58"
    avm_git_org              = "Azure"
    avm_git_repo             = "terraform-azurerm-alz-management"
    avm_yor_name             = "management"
    avm_yor_trace            = "ca9ea96b-2774-488d-b837-1a80562c2237"
  } /*<box>*/ : replace(k, "avm_", var.tracing_tags_prefix) => v } : {}) /*</box>*/))

  depends_on = [
    azurerm_resource_group.management,
  ]
}


resource "azurerm_automation_account" "management" {
  count = var.deploy_linked_automation_account ? 1 : 0

  location                      = var.location
  name                          = var.automation_account_name
  resource_group_name           = var.resource_group_name
  sku_name                      = var.automation_account_sku_name
  local_authentication_enabled  = var.automation_account_local_authentication_enabled
  public_network_access_enabled = var.automation_account_public_network_access_enabled
  tags = merge(var.tags, (/*<box>*/ (var.tracing_tags_enabled ? { for k, v in /*</box>*/ {
    avm_git_commit           = "ba28d2019d124ec455bed690e553fe9c7e4e2780"
    avm_git_file             = "main.tf"
    avm_git_last_modified_at = "2023-05-15 11:25:58"
    avm_git_org              = "Azure"
    avm_git_repo             = "terraform-azurerm-alz-management"
    avm_yor_name             = "management"
    avm_yor_trace            = "71332c85-180c-4955-9b9c-09c6c1fd2613"
  } /*<box>*/ : replace(k, "avm_", var.tracing_tags_prefix) => v } : {}) /*</box>*/))

  dynamic "encryption" {
    for_each = var.automation_account_encryption == null ? [] : ["Encryption"]

    content {
      key_vault_key_id          = var.automation_account_encryption.key_vault_key_id
      user_assigned_identity_id = var.automation_account_encryption.user_assigned_identity_id
    }
  }
  dynamic "identity" {
    for_each = var.automation_account_identity == null ? [] : ["Identity"]

    content {
      type         = var.automation_account_identity.type
      identity_ids = var.automation_account_identity.identity_ids
    }
  }

  depends_on = [
    azurerm_resource_group.management,
  ]
}

resource "azurerm_log_analytics_linked_service" "management" {
  count = var.deploy_linked_automation_account ? 1 : 0

  resource_group_name = var.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.management.id
  read_access_id      = azurerm_automation_account.management[0].id
  write_access_id     = null

  depends_on = [
    azurerm_automation_account.management,
    azurerm_log_analytics_workspace.management,
    azurerm_resource_group.management,
  ]
}

resource "azurerm_log_analytics_solution" "management" {
  for_each = { for plan in toset(var.log_analytics_solution_plans) : "${plan.publisher}/${plan.product}" => plan }

  location              = var.location
  resource_group_name   = var.resource_group_name
  solution_name         = basename(each.value.product)
  workspace_name        = var.log_analytics_workspace_name
  workspace_resource_id = azurerm_log_analytics_workspace.management.id
  tags = merge(var.tags, (/*<box>*/ (var.tracing_tags_enabled ? { for k, v in /*</box>*/ {
    avm_git_commit           = "51687c5014c6b8d7005c26e0258dc1050d10dd01"
    avm_git_file             = "main.tf"
    avm_git_last_modified_at = "2023-05-19 12:45:10"
    avm_git_org              = "Azure"
    avm_git_repo             = "terraform-azurerm-alz-management"
    avm_yor_name             = "management"
    avm_yor_trace            = "5e62436e-6232-47b9-9713-39a050e36c8c"
  } /*<box>*/ : replace(k, "avm_", var.tracing_tags_prefix) => v } : {}) /*</box>*/))

  plan {
    product   = each.value.product
    publisher = each.value.publisher
  }

  depends_on = [
    azurerm_automation_account.management,
    azurerm_log_analytics_linked_service.management,
    azurerm_log_analytics_workspace.management,
    azurerm_resource_group.management,
  ]
}
