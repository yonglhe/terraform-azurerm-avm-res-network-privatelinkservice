# terraform-azurerm-avm-privatelinkservice

Module to deploy a Private Link Service in Terraform

## Load Balancer Requirement

A Private Link Service **requires** a Standard Load Balancer frontend IP configuration. This module supports the following mutually exclusive options (exactly **one** option must be used.):

#### Option 1 – Resource Load Balancer (Default) OR Existing Load Balancer
Description: The module will attach the created separate Standard Load Balancer or the module will attach the Private Link Service to the existing Load Balancer.
- Provide `load_balancer_frontend_ip_configuration_ids` directly.
Type: `list(string)`

OR
- Provide:
  - `existing_load_balancer_id`
Type: `string`
  - `existing_load_balancer_frontend_ip_configuration_ids`
Type: `list(string)`

#### Option 2 – Module-created built-in Load Balancer (Recommended)
Description: The module will create a Standard Load Balancer and attach it to the Private Link Service.
- Provide `load_balancer_frontend_ip_configs`.

Type:

```hcl
list(object({
    name                 = string
    subnet_id            = optional(string)
    private_ip_address   = optional(string)
    public_ip_address_id = optional(string)
  }))
```
