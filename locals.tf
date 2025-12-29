locals {
  create_lb = var.existing_load_balancer_id == null && length(var.load_balancer_frontend_ip_configs) > 0
  # Frontend IP configuration IDs used by the Private Link Service
  frontend_ids = (
    # Option 1: Existing Load Balancer
    local.use_existing_lb ? var.existing_load_balancer_frontend_ip_configuration_ids :
    # Option 2: Module-created Load Balancer
    [for cfg in try(azurerm_lb.this[0].frontend_ip_configuration, []) : cfg.id]
  )
  role_definition_resource_substring = "/providers/Microsoft.Authorization/roleDefinitions"
  use_existing_lb                    = var.existing_load_balancer_id != null
}
