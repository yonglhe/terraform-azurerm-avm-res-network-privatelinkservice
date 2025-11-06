variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "dev-avm-pls-test"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "North Europe"
}
