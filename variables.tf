variable "location" {
  type        = string
  description = "(Required) Azure region were the resource should be deployed."
  nullable    = false
}

variable "name" {
  type        = string
  description = "(Required) The name of this resource"

  validation {
    error_message = "The name must be between 5 and 50 characters long and can only contain letters, numbers and dashes."
    condition     = can(regex("^[a-zA-Z0-9-]{5,50}$", var.name))
  }
  validation {
    error_message = "The name must not contain two consecutive dashes"
    condition     = !can(regex("--", var.name))
  }
  validation {
    error_message = "The name must start with a letter"
    condition     = can(regex("^[a-zA-Z]", var.name))
  }
  validation {
    error_message = "The name must end with a letter or number"
    condition     = can(regex("[a-zA-Z0-9]$", var.name))
  }
}

variable "nat_ip_configurations" {
  type = list(object({
    name                       = string
    subnet_id                  = string
    primary                    = bool
    private_ip_address         = optional(string, null)
    private_ip_address_version = optional(string, null)
  }))
  description = <<-DESCRIPTION
(Required) List of NAT IP configuration blocks for the Private Link Service.
This includes the following properties:
- name - (Required)The name for the NAT IP configuration.
- private_ip_address - (Optional)The private static IP address for this configuration.
- private_ip_address_version - (Optional) The version of the private static IP address.
- subnet_id - (Required) The ID of the subnet for the private link service.
- primary - (Required) Set this IP configurations as primary, changing this foces a new resource to be created.
DESCRIPTION

  validation {
    condition     = length(var.nat_ip_configurations) <= 8
    error_message = "You can create a maximum of 8 NAT IP configurations."
  }
}

variable "resource_group_name" {
  type        = string
  description = "(Required) The resource group where the resources will be deployed."
}

variable "auto_approval_subscription_ids" {
  type        = list(string)
  default     = []
  description = "(Optional) A list of subscription IDs that will be automatically approved to connect to the Private Link Service."
}

variable "diagnostic_settings" {
  type = map(object({
    name                                     = optional(string, null)
    log_categories                           = optional(set(string), [])
    log_groups                               = optional(set(string), ["allLogs"])
    metric_categories                        = optional(set(string), ["AllMetrics"])
    log_analytics_destination_type           = optional(string, "Dedicated")
    workspace_resource_id                    = optional(string, null)
    storage_account_resource_id              = optional(string, null)
    event_hub_authorization_rule_resource_id = optional(string, null)
    event_hub_name                           = optional(string, null)
    marketplace_partner_resource_id          = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
A map of diagnostic settings to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `name` - (Optional) The name of the diagnostic setting. One will be generated if not set, however this will not be unique if you want to create multiple diagnostic setting resources.
- `log_categories` - (Optional) A set of log categories to send to the log analytics workspace. Defaults to `[]`.
- `log_groups` - (Optional) A set of log groups to send to the log analytics workspace. Defaults to `["allLogs"]`.
- `metric_categories` - (Optional) A set of metric categories to send to the log analytics workspace. Defaults to `["AllMetrics"]`.
- `log_analytics_destination_type` - (Optional) The destination type for the diagnostic setting. Possible values are `Dedicated` and `AzureDiagnostics`. Defaults to `Dedicated`.
- `workspace_resource_id` - (Optional) The resource ID of the log analytics workspace to send logs and metrics to.
- `storage_account_resource_id` - (Optional) The resource ID of the storage account to send logs and metrics to.
- `event_hub_authorization_rule_resource_id` - (Optional) The resource ID of the event hub authorization rule to send logs and metrics to.
- `event_hub_name` - (Optional) The name of the event hub. If none is specified, the default event hub will be selected.
- `marketplace_partner_resource_id` - (Optional) The full ARM resource ID of the Marketplace resource to which you would like to send Diagnostic LogsLogs.
DESCRIPTION
  nullable    = false

  validation {
    condition     = alltrue([for _, v in var.diagnostic_settings : contains(["Dedicated", "AzureDiagnostics"], v.log_analytics_destination_type)])
    error_message = "Log analytics destination type must be one of: 'Dedicated', 'AzureDiagnostics'."
  }
  validation {
    condition = alltrue(
      [
        for _, v in var.diagnostic_settings :
        v.workspace_resource_id != null || v.storage_account_resource_id != null || v.event_hub_authorization_rule_resource_id != null || v.marketplace_partner_resource_id != null
      ]
    )
    error_message = "At least one of `workspace_resource_id`, `storage_account_resource_id`, `marketplace_partner_resource_id`, or `event_hub_authorization_rule_resource_id`, must be set."
  }
}

variable "enable_proxy_protocol" {
  type        = bool
  default     = false
  description = "(Optional) The support for the Proxy Protocol for te Private Link Service"
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
  nullable    = false
}

variable "existing_load_balancer_frontend_ip_configuration_ids" {
  type    = list(string)
  default = []
  # description = ""
  description = <<-DESCRIPTION
(Optional) Frontend IP configuration IDs belonging to the existing load balancer provided in existing_load_balancer_id.
*(for creating the load balancer inside the module) - load_balancer_frontend_ip_configs for a module-created load balancer
DESCRIPTION

  validation {
    condition     = var.existing_load_balancer_id == null || length(var.existing_load_balancer_frontend_ip_configuration_ids) > 0
    error_message = "If existing_load_balancer_id is provided, you must provide its frontend IP configuration IDs."
  }
}

variable "existing_load_balancer_id" {
  type        = string
  default     = null
  description = <<-DESCRIPTION
(Optional) ID of an existing Standard Load Balancer. If provided, you must also provide its frontend IP configuration IDs.
*(for existing load balancer) - existing_load_balancer_id & existing_load_balancer_frontend_ip_configuration_ids
DESCRIPTION
}

variable "load_balancer_frontend_ip_configs" {
  type = list(object({
    name                 = string
    subnet_id            = optional(string)
    private_ip_address   = optional(string)
    public_ip_address_id = optional(string)
  }))
  default     = []
  description = "(Optional) To deploy the Standard Load balancer together with Private Link Service inside the module."

  validation {
    condition = (
      # Option 1: existing LB + its frontend IDs
      (
        var.existing_load_balancer_id != null &&
        length(var.existing_load_balancer_frontend_ip_configuration_ids) > 0
      )
      ||
      # Option 2: module-created LB configs
      (
        length(var.load_balancer_frontend_ip_configs) > 0
      )
    )
    error_message = <<-EOF
  (Required) You must provide one of the following:
    1. (for existing load balancer)                         existing_load_balancer_id & existing_load_balancer_frontend_ip_configuration_ids
    2. (for creating the load balancer inside the module)   load_balancer_frontend_ip_configs for a module-created load balancer
  A Private Link Service requires exactly one load balancer frontend IP configuration in all Terraform-supported scenarios.
  EOF
  }
}

variable "lock" {
  type = object({
    kind = string
    name = optional(string, null)
  })
  default     = null
  description = <<DESCRIPTION
Controls the Resource Lock configuration for this resource. The following properties can be specified:

- `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
- `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.
DESCRIPTION

  validation {
    condition     = var.lock != null ? contains(["CanNotDelete", "ReadOnly"], var.lock.kind) : true
    error_message = "The lock level must be one of: 'None', 'CanNotDelete', or 'ReadOnly'."
  }
}

variable "role_assignments" {
  type = map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
    principal_type                         = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
A map of role assignments to create on this resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
- `principal_id` - The ID of the principal to assign the role to.
- `description` - The description of the role assignment.
- `skip_service_principal_aad_check` - If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
- `condition` - The condition which will be used to scope the role assignment.
- `condition_version` - The version of the condition syntax. Valid values are '2.0'.
- `delegated_managed_identity_resource_id` - The delegated Azure Resource Id which contains a Managed Identity. Changing this forces a new resource to be created.
- `principal_type` - The type of the principal_id. Possible values are `User`, `Group` and `ServicePrincipal`. Changing this forces a new resource to be created. It is necessary to explicitly set this attribute when creating role assignments if the principal creating the assignment is constrained by ABAC rules that filters on the PrincipalType attribute.

> Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.

Example Input:

  ```terraform
  role_assignments ={
    "object1" = {
      role_definition_id_or_name = "<role_definition_1_name>"
      principal_id               = "<object_id_of_the_principal>"
    },
    "object2" = {
      role_definition_id_or_name = "<role_definition_2_name>"
      principal_id               = "<object_id_of_the_principal>"
      description                = "<description>"
    },
  }
  ```
DESCRIPTION
  nullable    = false
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags of the resource."
}

variable "visibility_subscription_ids" {
  type        = list(string)
  default     = []
  description = "(Optional) A list of subscription IDs that have visibility to the Private Link Service"
}
