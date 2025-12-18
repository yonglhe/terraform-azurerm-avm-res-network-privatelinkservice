locals {
  create_lb = var.existing_load_balancer_id == null && length(var.load_balancer_frontend_ip_configs) > 0
  # Frontend IDs depend on LB mode
  frontend_ids = (
    # Option 1: Existing LB
    local.use_existing_lb ? var.existing_load_balancer_frontend_ip_configuration_ids :
    # Option 2: Module-created LB
    local.create_lb ? [for cfg in try(azurerm_lb.this[0].frontend_ip_configuration, []) : cfg.id] :
    # Option 3: Deprecated user-supplied IDs
    var.load_balancer_frontend_ip_configuration_ids
  )
  role_definition_resource_substring = "/providers/Microsoft.Authorization/roleDefinitions"
  use_existing_lb                    = var.existing_load_balancer_id != null
}
