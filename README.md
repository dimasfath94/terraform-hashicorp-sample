to remove existing ldap configuration:
terraform state rm vault_ldap_secret_backend.config vault_ldap_secret_backend_static_role.role 2>/dev/null || true


to apply:
terraform apply


sample steps:

export VAULT_TOKEN="YOUR_TOKEN"

docker start my-openldap-server


docker exec -i my-openldap-server ldapadd -x -H ldap://localhost -D "cn=admin,dc=example,dc=org" -w admin -f /dev/stdin < ~/vault/user-only.ldif


cd terraform/


terraform apply


docker exec -it my-openldap-server ldapsearch -x -H ldap://localhost:389 -D "uid=svc-database,ou=users,dc=example,dc=org" -w "RETRIEVE NEW PASS" -b "uid=svc-database,ou=users,dc=example,dc=org" "(objectClass=*)"


get from api
curl -s --header "X-Vault-Token: YOUR_TOKEN" https://127.0.0.1:8200/v1/ldap/static-cred/app-ldap-role --insecure

