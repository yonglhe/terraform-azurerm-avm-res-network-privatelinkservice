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
  value       = azurerm_private_link_service.this.nat_ip_configuration
}
