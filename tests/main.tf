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

resource "azurerm_resource_group" "this" {
  name     = "${var.name_prefix}-rg"
  location = var.location
}

resource "azurerm_virtual_network" "this" {
  name                = "${var.name_prefix}-vnet"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "pls_subnet" {
  name                 = "${var.name_prefix}-subnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.3.0/24"]

  private_link_service_network_policies_enabled = false
}

resource "azurerm_subnet" "lb_subnet" {
  name                 = "${var.name_prefix}-lb-subnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.2.0/24"]

  private_link_service_network_policies_enabled = false
}

resource "azurerm_lb" "this" {
  name                = "${var.name_prefix}-lb"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "${var.name_prefix}-lb-frontend-ip"
    subnet_id                     = azurerm_subnet.lb_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

module "azurerm_private_link_service" {
  source = "/mnt/c/Users/yhe/terraform-azure/core/core-terraform-azurerm-avm-res-network-privatelinkservice/"

  name                  = "${var.name_prefix}-private-link-service"
  resource_group_name   = azurerm_resource_group.this.name
  location              = azurerm_resource_group.this.location
  enable_proxy_protocol = false

  load_balancer_frontend_ip_configuration_ids = [
    azurerm_lb.this.frontend_ip_configuration[0].id
    ]

  visibility_subscription_ids = ["fa149c5d-7408-4687-8c05-0741bb84b780", "00000000-0000-0000-0000-000000000000"]
  auto_approval_subscription_ids = ["fa149c5d-7408-4687-8c05-0741bb84b780", "00000000-0000-0000-0000-000000000000"]

  nat_ip_configurations = [
    {
      name                       = "primary"
      subnet_id                  = azurerm_subnet.pls_subnet.id
      primary                    = true
      private_ip_address_version = "IPv4"
      private_ip_address         = "10.0.3.4"
    }
  ]
}
