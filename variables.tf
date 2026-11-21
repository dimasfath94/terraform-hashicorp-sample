variable "vault_address" {
  description = "Vault server endpoint URL."
  type        = string
  default     = "https://127.0.0.1:8200"
}

variable "vault_skip_tls_verify" {
  description = "Skip TLS certificate verification when connecting to Vault."
  type        = bool
  default     = true
}

variable "ldap_backends" {
  description = "Map of LDAP secret backend configurations for OpenLDAP, Active Directory, or other directory services."
  type = map(object({
    path         = string
    url          = string
    binddn       = string
    bindpass     = optional(string, null)
    userdn       = string
    userattr     = optional(string, "uid")
    schema       = optional(string, "openldap")
    insecure_tls = optional(bool, false)
    starttls     = optional(bool, false)
  }))
  default = {}
}

variable "ldap_default_bindpass" {
  description = "Default LDAP bind password supplied via TF_VAR_ldap_default_bindpass environment variable."
  type        = string
  sensitive   = true
  default     = null
}

variable "ldap_bindpasses" {
  description = "Optional map of LDAP bind passwords keyed by ldap_backends map key, supplied via TF_VAR_ldap_bindpasses."
  type        = map(string)
  sensitive   = true
  default     = {}
}

variable "ldap_static_roles" {
  description = "Map of LDAP static roles managing service account credentials across directory OUs."
  type = map(object({
    backend_key     = string
    role_name       = string
    username        = string
    dn              = optional(string, null)
    rotation_period = number
  }))
  default = {}
}

variable "database_backends" {
  description = "Map of database secret backend mounts and connection configurations."
  type = map(object({
    path                = string
    plugin_name         = string
    allowed_roles       = list(string)
    connection_name     = string
    verify_connection   = optional(bool, false)
    connection_settings = map(string)
  }))
  default = {}
}

variable "database_static_roles" {
  description = "Map of database static roles bound to existing database accounts."
  type = map(object({
    backend_key     = string
    role_name       = string
    db_name         = string
    username        = string
    rotation_period = number
  }))
  default = {}
}

variable "kv_mounts" {
  description = "Map of KV v2 secret engines for general application configuration."
  type = map(object({
    path         = string
    description  = string
    max_versions = optional(number, 5)
  }))
  default = {}
}
