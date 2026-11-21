terraform {
  required_version = ">= 1.5.0"
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = ">= 3.25.0, < 5.0"
    }
  }
}

provider "vault" {
  address         = var.vault_address
  skip_tls_verify = var.vault_skip_tls_verify
}

# --- LDAP Secret Backends (OpenLDAP / Active Directory / Generic LDAP) ---
resource "vault_ldap_secret_backend" "this" {
  for_each = var.ldap_backends

  path = each.value.path
  url  = each.value.url
  binddn = each.value.binddn
  bindpass = coalesce(
    each.value.bindpass,
    lookup(var.ldap_bindpasses, each.key, null),
    var.ldap_default_bindpass
  )
  userdn       = each.value.userdn
  userattr     = each.value.userattr
  schema       = each.value.schema
  insecure_tls = each.value.insecure_tls
  starttls     = each.value.starttls

  lifecycle {
    ignore_changes = [bindpass]

    precondition {
      condition     = strcontains(lower(each.value.userdn), "ou=hashicorp")
      error_message = "LDAP backend '${each.key}' userdn must include ou=Hashicorp."
    }
  }
}

# --- LDAP Static Roles ---
resource "vault_ldap_secret_backend_static_role" "this" {
  for_each = var.ldap_static_roles

  mount           = vault_ldap_secret_backend.this[each.value.backend_key].path
  role_name       = each.value.role_name
  username        = each.value.username
  dn              = each.value.dn
  rotation_period = each.value.rotation_period

  depends_on = [vault_ldap_secret_backend.this]

  lifecycle {
    precondition {
      condition = (
        strcontains(lower(var.ldap_backends[each.value.backend_key].userdn), "ou=hashicorp") &&
        (each.value.dn == null ? true : strcontains(lower(each.value.dn), "ou=hashicorp"))
      )
      error_message = "LDAP static role '${each.value.role_name}' requires ou=Hashicorp in backend userdn or role dn."
    }
  }
}

# --- Database Secret Backends ---
resource "vault_mount" "db" {
  for_each = var.database_backends

  path        = each.value.path
  type        = "database"
  description = "Database secrets engine for ${each.key}."
}

resource "vault_database_secret_backend_connection" "this" {
  for_each = var.database_backends

  backend           = vault_mount.db[each.key].path
  name              = each.value.connection_name
  allowed_roles     = each.value.allowed_roles
  verify_connection = each.value.verify_connection

  dynamic "postgresql" {
    for_each = each.value.plugin_name == "postgresql-database-plugin" ? [1] : []
    content {
      connection_url = each.value.connection_settings["connection_url"]
      username       = each.value.connection_settings["username"]
      password       = each.value.connection_settings["password"]
    }
  }

  dynamic "mssql" {
    for_each = each.value.plugin_name == "mssql-database-plugin" ? [1] : []
    content {
      connection_url = each.value.connection_settings["connection_url"]
      username       = each.value.connection_settings["username"]
      password       = each.value.connection_settings["password"]
    }
  }
}

# --- Database Static Roles ---
resource "vault_database_secret_backend_static_role" "this" {
  for_each = var.database_static_roles

  backend         = vault_mount.db[each.value.backend_key].path
  name            = each.value.role_name
  db_name         = each.value.db_name
  username        = each.value.username
  rotation_period = each.value.rotation_period

  depends_on = [vault_database_secret_backend_connection.this]
}

# --- KV v2 Secret Engines ---
resource "vault_mount" "kv" {
  for_each = var.kv_mounts

  path        = each.value.path
  type        = "kv-v2"
  description = each.value.description
  options = {
    version = "2"
  }
}
