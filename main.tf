provider "vault" {
  address         = "https://127.0.0.1:8200"
  skip_tls_verify = true
}

resource "vault_ldap_secret_backend" "config" {
  path     = "ldap"
  url      = "ldap://my-openldap-server:389"
  binddn   = "cn=admin,dc=example,dc=org"
  bindpass = "admin"
  userdn   = "ou=users,dc=example,dc=org"
  userattr = "uid"
  schema   = "openldap"
}

resource "vault_ldap_secret_backend_static_role" "role" {
  mount           = vault_ldap_secret_backend.config.path
  role_name       = "app-ldap-role"
  username        = "svc-database"
  rotation_period = 2764800 # 32 hari dalam detik

  depends_on = [vault_ldap_secret_backend.config]
}
