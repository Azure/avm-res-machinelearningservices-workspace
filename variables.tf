variable "location" {
  type        = string
  description = "Azure region where the resource should be deployed."
  nullable    = false
}

variable "name" {
  type        = string
  description = "The name of the this resource."
}

# This is required for most resource modules
variable "resource_group" {
  type = object({
    id   = string
    name = string
  })
  description = <<DESCRIPTION
An object describing the resource group to deploy the resource to. This includes the following properties:
- `id` - The resource ID of the resource group.
- `name` - The name of the resource group.
DESCRIPTION
  nullable    = false
}

variable "subnets" {
  type = map(object({
    name              = string
    address_prefix    = string
    service_endpoints = list(string)
    nsg_id            = string
  }))
  description = "A map of subnet definitions"
}

variable "associated_container_registry" {
  type = object({
    resource_id = string
  })
  default     = null
  description = <<DESCRIPTION
An object describing the Container Registry to associate with the resource. This includes the following properties:
- `resource_id` - The resource ID of the Container Registry.
DESCRIPTION
}

variable "associated_key_vault" {
  type = object({
    resource_id = string
  })
  default     = null
  description = <<DESCRIPTION
An object describing the Key Vault to associate with the resource. This includes the following properties:
- `resource_id` - The resource ID of the Key Vault.
DESCRIPTION
}

variable "associated_storage_account" {
  type = object({
    resource_id = string
  })
  default     = null
  description = <<DESCRIPTION
An object describing the Storage Account to associate with the resource. This includes the following properties:
- `resource_id` - The resource ID of the Storage Account.
DESCRIPTION
}

variable "associated_vnet" {
  type = object({
    resource_id = string
  })
  default     = null
  description = <<DESCRIPTION
An object describing the Virtual Network to associate with the resource. This includes the following properties:
- `resource_id` - The resource ID of the Virtual Network.
DESCRIPTION
}

variable "container_registry" {
  type = object({
    private_dns_zone_resource_map = optional(map(set(string)), null)
  })
  default     = null
  description = <<DESCRIPTION
An object describing the Container Registry to create the private endpoint connection to. This includes the following properties:
- `private_dns_zone_resource_map` - A map of private DNS zones to associate with the private endpoint.
DESCRIPTION
}

# required AVM interfaces
# remove only if not supported by the resource
# tflint-ignore: terraform_unused_declarations
variable "customer_managed_key" {
  type = object({
    key_vault_resource_id = string
    key_name              = string
    key_version           = optional(string, null)
    user_assigned_identity = optional(object({
      resource_id = string
    }), null)
  })
  default     = null
  description = <<DESCRIPTION
A map describing customer-managed keys to associate with the resource. This includes the following properties:
- `key_vault_resource_id` - The resource ID of the Key Vault where the key is stored.
- `key_name` - The name of the key.
- `key_version` - (Optional) The version of the key. If not specified, the latest version is used.
- `user_assigned_identity` - (Optional) An object representing a user-assigned identity with the following properties:
  - `resource_id` - The resource ID of the user-assigned identity.
DESCRIPTION  
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
}

variable "hbi_workspace" {
  type        = bool
  default     = false
  description = "Specifies if the resource is a High Business Impact (HBI) workspace."
}

variable "is_private" {
  type        = bool
  default     = false
  description = "Specifies if the resource is private."
}

variable "key_vault" {
  type = object({
    private_dns_zone_resource_map = optional(map(set(string)), null)
  })
  default     = null
  description = <<DESCRIPTION
An object describing the Key Vault to create the private endpoint connection to. This includes the following properties:
- `private_dns_zone_resource_map` - A map of private DNS zones to associate with the private endpoint.
DESCRIPTION
}

variable "kind" {
  type        = string
  default     = null
  description = <<DESCRIPTION
The kind of the resource. This is used to determine the type of the resource. If not specified, the resource will be created as a standard resource.
Possible values are:
- `null` - The resource will be created as a standard Azure Machine Learning resource.
- `hub` - The resource will be created as an AI Hub resource.
- `project` - The resource will be created as an AI Studio Project resource.
DESCRIPTION
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

variable "private_endpoints" {
  type = map(object({
    name = optional(string, null)
    role_assignments = optional(map(object({
      role_definition_id_or_name             = string
      principal_id                           = string
      description                            = optional(string, null)
      skip_service_principal_aad_check       = optional(bool, false)
      condition                              = optional(string, null)
      condition_version                      = optional(string, null)
      delegated_managed_identity_resource_id = optional(string, null)
      principal_type                         = optional(string, null)
    })), {})
    lock = optional(object({
      kind = string
      name = optional(string, null)
    }), null)
    tags                                    = optional(map(string), null)
    subnet_resource_id                      = string
    subresource_name                        = string
    private_dns_zone_group_name             = optional(string, "default")
    private_dns_zone_resource_ids           = optional(set(string), [])
    application_security_group_associations = optional(map(string), {})
    private_service_connection_name         = optional(string, null)
    network_interface_name                  = optional(string, null)
    location                                = optional(string, null)
    resource_group_name                     = optional(string, null)
    ip_configurations = optional(map(object({
      name               = string
      private_ip_address = string
    })), {})
  }))
  default     = {}
  description = <<DESCRIPTION
A map of private endpoints to create on this resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `name` - (Optional) The name of the private endpoint. One will be generated if not set.
- `role_assignments` - (Optional) A map of role assignments to create on the private endpoint. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time. See `var.role_assignments` for more information.
- `lock` - (Optional) The lock level to apply to the private endpoint. Default is `None`. Possible values are `None`, `CanNotDelete`, and `ReadOnly`.
- `tags` - (Optional) A mapping of tags to assign to the private endpoint.
- `subnet_resource_id` - The resource ID of the subnet to deploy the private endpoint in.
- `private_dns_zone_group_name` - (Optional) The name of the private DNS zone group. One will be generated if not set.
- `private_dns_zone_resource_ids` - (Optional) A set of resource IDs of private DNS zones to associate with the private endpoint. If not set, no zone groups will be created and the private endpoint will not be associated with any private DNS zones. DNS records must be managed external to this module.
- `application_security_group_resource_ids` - (Optional) A map of resource IDs of application security groups to associate with the private endpoint. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
- `private_service_connection_name` - (Optional) The name of the private service connection. One will be generated if not set.
- `network_interface_name` - (Optional) The name of the network interface. One will be generated if not set.
- `location` - (Optional) The Azure location where the resources will be deployed. Defaults to the location of the resource group.
- `resource_group_name` - (Optional) The resource group where the resources will be deployed. Defaults to the resource group of this resource.
- `ip_configurations` - (Optional) A map of IP configurations to create on the private endpoint. If not specified the platform will create one. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
  - `name` - The name of the IP configuration.
  - `private_ip_address` - The private IP address of the IP configuration.
DESCRIPTION
  nullable    = false
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

> Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.
DESCRIPTION
  nullable    = false
}

variable "shared_subnet_id" {
  type        = string
  default     = null
  description = "The resource ID of the subnet to associate with the resource."
}

variable "storage_account" {
  type = object({
    private_dns_zone_resource_map = optional(map(set(string)), null)
  })
  default     = null
  description = <<DESCRIPTION
An object describing the Storage Account to create the private endpoint connection to. This includes the following properties:
- `private_dns_zone_resource_map` - A map of private DNS zones to associate with the private endpoint.
DESCRIPTION
}

# tflint-ignore: terraform_unused_declarations
variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags of the resource."
}

variable "vnet_address_space" {
  type        = list(string)
  default     = ["10.0.0.0/16"]
  description = "The address space that is used by the Virtual Network"
}
