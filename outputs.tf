output "alias" {
  description = "The alias of the Private Link Service."
  value       = azurerm_private_link_service.this.alias
}

output "auto_approval_subscription_ids" {
  description = "The list of subscription IDs that have auto approval to the Private Link Service."
  value       = azurerm_private_link_service.this.auto_approval_subscription_ids
}

output "id" {
  description = "ID of the resource"
  value       = azurerm_private_link_service.this.id
}

output "load_balancer_frontend_ip_configuration_ids" {
  description = "The frontend IP configuration IDs used by the Private Link Service."
  value       = local.frontend_ids
}

output "load_balancer_id" {
  description = "The ID of the module-created Standard Load Balancer (if created). Null if using an existing LB."
  value       = local.create_lb ? azurerm_lb.this[0].id : null
}

output "name" {
  description = "Name of the resource."
  value       = azurerm_private_link_service.this.name
}

output "nat_ip_configurations" {
  description = "The NAT IP configurations used by this Private Link Service."
  value       = azurerm_private_link_service.this.nat_ip_configuration
}

output "resource" {
  description = "Output of the resource."
  value       = azurerm_private_link_service.this
}

output "visibility_subscription_ids" {
  description = "The list of subscription IDs that have visibility to the Private Link Service."
  value       = azurerm_private_link_service.this.visibility_subscription_ids
}
