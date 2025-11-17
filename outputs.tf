output "name" {
  description = "Name of the resource."
  value       = azurerm_private_link_service.this.name
}

output "resource" {
  description = "Output of the resource."
  value       = azurerm_private_link_service.this
}

output "id" {
  description = "ID of the resource"
  value       = azurerm_private_link_service.this.id
}

output "alias" {
  description = "The alias of the Private Link Service."
  value       = azurerm_private_link_service.this.alias
}

output "nat_ip_configurations" {
  description = "The NAT IP configurations used by this Private Link Service."
  value       = var.nat_ip_configurations
}

output "visibility_subscription_ids" {
  description = "The list of subscription IDs that have visibility to the Private Link Service."
  value = azurerm_private_link_service.this.visibility_subscription_ids
}

output "auto_approval_subscription_ids" {
  description = "The list of subscription IDs that have auto approval to the Private Link Service."
  value = azurerm_private_link_service.this.auto_approval_subscription_ids
}
