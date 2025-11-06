resource "azurerm_private_link_service" "this" {
  name                    = var.name
  location                = var.location
  resource_group_name     = var.resource_group_name

  enable_proxy_protocol = var.enable_proxy_protocol

  dynamic nat_ip_configuration {
    for_each = var.nat_ip_configurations
    content {
      name                          = nat_ip_configuration.value.name
      subnet_id                     = nat_ip_configuration.value.subnet_id
      primary                       = nat_ip_configuration.value.primary
      private_ip_address            = try(nat_ip_configuration.value.private_ip_address, "10.0.3.4")
      private_ip_address_version    = try(nat_ip_configuration.value.private_ip_address_version, "IPv4")
    }
  }

  load_balancer_frontend_ip_configuration_ids = var.load_balancer_frontend_ip_configuration_ids
  auto_approval_subscription_ids = var.auto_approval != null ? var.auto_approval.subscription_ids : null
  visibility_subscription_ids = var.visibility != null ? var.visibility.subscription_ids : null

  tags     = var.tags
}
#********************************************************************************************

# # required AVM resources interfaces
# resource "azurerm_management_lock" "this" {
#   count = var.lock != null ? 1 : 0

#   lock_level = var.lock.kind
#   name       = coalesce(var.lock.name, "lock-${var.lock.kind}")
#   scope      = azurerm_private_link_service.this.id
#   notes      = var.lock.kind == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources."
# }

# resource "azurerm_role_assignment" "this" {
#   for_each = var.role_assignments

#   principal_id                           = each.value.principal_id
#   scope                                  = azurerm_private_link_service.this.id
#   condition                              = each.value.condition
#   condition_version                      = each.value.condition_version
#   delegated_managed_identity_resource_id = each.value.delegated_managed_identity_resource_id
#   principal_type                         = each.value.principal_type
#   role_definition_id                     = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role_definition_id_or_name : null
#   role_definition_name                   = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? null : each.value.role_definition_id_or_name
#   skip_service_principal_aad_check       = each.value.skip_service_principal_aad_check
# }
