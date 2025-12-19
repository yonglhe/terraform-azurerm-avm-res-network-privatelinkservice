terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.7.0, < 5.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0, < 4.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

## Section to provide a random Azure region for the resource group
# This allows us to randomize the region for the resource group.
module "regions" {
  source  = "Azure/avm-utl-regions/azurerm"
  version = "0.3.0"
}

# This allows us to randomize the region for the resource group.
resource "random_integer" "region_index" {
  max = length(module.regions.regions) - 1
  min = 0
}

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.2"
}

# Naming module specifically for the "pls" subnet
module "naming_pls_subnet" {
  source  = "Azure/naming/azurerm"
  version = "0.4.2"

  prefix = ["pls"] # <-- This makes the name unique
}

# Naming module specifically for the "lb" subnet
module "naming_lb_subnet" {
  source  = "Azure/naming/azurerm"
  version = "0.4.2"

  prefix = ["lb"] # <-- This makes the name unique
}

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  location = module.regions.regions[random_integer.region_index.result].name
  name     = module.naming.resource_group.name_unique
}

# This is required for resource modules
resource "azurerm_virtual_network" "this" {
  location            = azurerm_resource_group.this.location
  name                = module.naming.virtual_network.name_unique
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.0.0.0/16"]
}

# This is required for resource modules (subnet for Private Link Service)
resource "azurerm_subnet" "this" {
  address_prefixes                              = ["10.0.1.0/24"]
  name                                          = module.naming_pls_subnet.subnet.name_unique
  resource_group_name                           = azurerm_resource_group.this.name
  virtual_network_name                          = azurerm_virtual_network.this.name
  private_link_service_network_policies_enabled = false
}

# NOTE:
# The following resources are used for end-to-end testing only.
# The referenced Standard Load Balancer resource is created as the default examples
# Terraform configuration to allow deterministic CI testing.
resource "azurerm_subnet" "lb" {
  address_prefixes     = ["10.0.2.0/24"]
  name                 = module.naming_lb_subnet.subnet.name_unique
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
}

resource "azurerm_lb" "this" {
  location            = azurerm_resource_group.this.location
  name                = module.naming.lb.name_unique
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "internal"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.lb.id
  }
}
# END OF NOTE

# This is the module call
module "azurerm_private_link_service" {
  source = "../.."

  location = azurerm_resource_group.this.location
  name     = module.naming.private_link_service.name_unique
  nat_ip_configurations = [
    {
      name                       = "Primary"
      subnet_id                  = azurerm_subnet.this.id
      primary                    = true
      private_ip_address_version = "IPv4"
    }
  ]
  resource_group_name = azurerm_resource_group.this.name
  # Add the Load Balancer resource ID and Frontend IP configuraion ID -URL from the Azure Portal
  # For Example: /subscriptions/../resourceGroups/../providers/Microsoft.Network/loadBalancers/..
  existing_load_balancer_frontend_ip_configuration_ids = [azurerm_lb.this.frontend_ip_configuration[0].id] # Replace with Frontend IP configuration Resource ID
  existing_load_balancer_id                            = azurerm_lb.this.id                                # Replace with Load Balancer Resource ID
}
