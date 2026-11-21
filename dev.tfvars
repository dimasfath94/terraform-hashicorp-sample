vault_address         = "https://127.0.0.1:8200"
vault_skip_tls_verify = true

ldap_backends = {
  openldap_main = {
    path     = "ldap"
    url      = "ldap://my-openldap-server:389"
    binddn   = "cn=admin,dc=example,dc=org"
    userdn   = "ou=Hashicorp,dc=example,dc=org"
    userattr = "uid"
    schema   = "openldap"
  }
  # Example for Active Directory (uncomment and adjust when needed):
  # corp_ad = {
  #   path                        = "ldap-ad"
  #   url                         = "ldaps://ad.corp.local:636"
  #   binddn                      = "CN=vault-bind,OU=ServiceAccounts,DC=corp,DC=local"
  #   userdn                      = "OU=VaultManaged,DC=corp,DC=local"
  #   userattr                    = "sAMAccountName"
  #   enable_samaccountname_login = true
  #   schema                      = "ad"
  # }
}

ldap_static_roles = {
  app_ldap_role = {
    backend_key     = "openldap_main"
    role_name       = "app-ldap-role"
    username        = "svc-database"
    rotation_period = 2764800
  }
}

database_backends = {
  # Example SQL Server / PostgreSQL connection (keep password out of tfvars in real workflows):
  # mssql_main = {
  #   path              = "database"
  #   plugin_name       = "mssql-database-plugin"
  #   connection_name   = "sqlserver-demo"
  #   allowed_roles     = ["app-db-role"]
  #   verify_connection = false
  #   connection_settings = {
  #     connection_url = "sqlserver://host.docker.internal:1433"
  #     username       = "sa"
  #     password       = ""
  #   }
  # }
}

database_static_roles = {
  # app_db_role = {
  #   backend_key     = "mssql_main"
  #   role_name       = "app-db-role"
  #   db_name         = "sqlserver-demo"
  #   username        = "svc-database"
  #   rotation_period = 2764800
  # }
}

kv_mounts = {
  app_config = {
    path        = "secret"
    description = "Application configuration secrets engine."
  }
}
