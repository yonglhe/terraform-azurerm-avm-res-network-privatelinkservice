terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.4"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {
  }
}

resource "azurerm_resource_group" "test" {
  name     = "${var.name_prefix}-rg"
  location = var.location
}

resource "azurerm_virtual_network" "test" {
  name                = "${var.name_prefix}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "${var.name_prefix}-subnet"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.3.0/24"]

  private_link_service_network_policies_enabled = false
}

resource "azurerm_public_ip" "test" {
  name                = "${var.name_prefix}-public-ip"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "test" {
  name                = "${var.name_prefix}-lb-subnet"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "${var.name_prefix}-lb-frontend-ip"
    public_ip_address_id = azurerm_public_ip.test.id
  }
}


module "azurerm_private_link_service" {
  source = "/mnt/c/Users/yhe/terraform-azure/core/core-terraform-azurerm-avm-res-network-privatelinkservice/"  # path to your AVM module

  name                  = "${var.name_prefix}-private-link-service"
  resource_group_name   = azurerm_resource_group.test.name
  location              = azurerm_resource_group.test.location
  enable_proxy_protocol = false

  load_balancer_frontend_ip_configuration_ids = [azurerm_lb.test.frontend_ip_configuration[0].id]

  nat_ip_configurations = [
    {
      name                       = "primary"
      subnet_id                  = azurerm_subnet.test.id
      primary                    = true
      private_ip_address_version = "IPv4"
    }
  ]
}


# Access outputs
output "pls_resource_name" {
  value = module.azurerm_private_link_service.name
}

output "pls_resource_output" {
  value = module.azurerm_private_link_service.resource
}

output "pls_id" {
  value = module.azurerm_private_link_service.id
}

output "pls_alias" {
  value = module.azurerm_private_link_service.alias
}

output "pls_nat_ip_configs" {
  value = module.azurerm_private_link_service.nat_ip_configurations
}
