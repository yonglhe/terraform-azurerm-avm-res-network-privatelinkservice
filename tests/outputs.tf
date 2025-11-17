
output "alias" {
  value = module.azurerm_private_link_service.alias
  description = "The alias of the Private Link Service"
}

output "nat_ip_configs" {
  value = module.azurerm_private_link_service.nat_ip_configurations
  description = "The NAT IP configurations of the Private Link Service"
}

output "resource_group_name" {
  value =  azurerm_resource_group.this.name
  description = "The resource group name where all the resoruces are deployed"
}

output "resource_id" {
  value = module.azurerm_private_link_service.id
  description = "The resource id of the Private Link Service"
}

output "resource_name" {
  value = module.azurerm_private_link_service.name
  description = "The resource name of the Private Link Service"
}

output "pls_resource_output" {
  value = module.azurerm_private_link_service.resource
  description = "The whole resource output of the Private Link Service"
}

output "visibility_subscription_ids" {
  description = "The list of subscription IDs that have visibility to the Private Link Service."
  value = module.azurerm_private_link_service.visibility_subscription_ids
}

output "auto_approval_subscription_ids" {
  description = "The list of subscription IDs that have auto approval to the Private Link Service."
  value = module.azurerm_private_link_service.auto_approval_subscription_ids
}
