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
}

ldap_static_roles = {
  app_ldap_role = {
    backend_key     = "openldap_main"
    role_name       = "app-ldap-role"
    username        = "svc-database"
    rotation_period = 2764800
  }
}

kv_mounts = {
  app_config = {
    path        = "secret"
    description = "Application configuration secrets engine."
  }
}
