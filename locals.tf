locals {
  role_definition_resource_substring = "/providers/Microsoft.Authorization/roleDefinitions"

  create_lb       = var.existing_load_balancer_id == null && length(var.load_balancer_frontend_ip_configs) > 0
  use_existing_lb = var.existing_load_balancer_id != null

  # Frontend IDs depend on LB mode
  frontend_ids = (
    # Option 1: Existing LB
    local.use_existing_lb ? var.existing_load_balancer_frontend_ip_configuration_ids :

    # Option 2: Module-created LB
    local.create_lb ? [
      for cfg in try(azurerm_lb.this[0].frontend_ip_configuration, []) : cfg.id
    ] :

    # Option 3: Deprecated user-supplied IDs
    var.load_balancer_frontend_ip_configuration_ids
  )
  # frontend_ids = local.direct_connect ? [] : local.create_lb ? [for cfg in azurerm_lb.this[0].frontend_ip_configuration : cfg.id] : var.existing_load_balancer_frontend_ip_configuration_ids
}
