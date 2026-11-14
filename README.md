to remove existing ldap configuration:
terraform state rm vault_ldap_secret_backend.config vault_ldap_secret_backend_static_role.role 2>/dev/null || true


to apply:
terraform apply
