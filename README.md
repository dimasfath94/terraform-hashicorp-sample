to remove existing ldap configuration:
```bash
terraform state rm vault_ldap_secret_backend.config vault_ldap_secret_backend_static_role.role 2>/dev/null || true
```


to apply:
```bash
terraform apply
```
or:
```bash
terraform plan -var-file="dev.tfvars"
```
then
```bash
terraform apply -auto-approve -var-file="dev.tfvars"
```


sample steps:
```bash
export VAULT_ADDR='https://127.0.0.1:8200'
```
```bash
export VAULT_SKIP_VERIFY='true'
```
```bash
export VAULT_TOKEN="YOUR_TOKEN"
```
```bash
export TF_VAR_ldap_default_bindpass='admin'
```

Start LDAP
```bash
docker start my-openldap-server
```

add user

```bash
docker exec -i my-openldap-server ldapadd -x -H ldap://localhost -D "cn=admin,dc=example,dc=org" -w admin -f /dev/stdin < ~/vault/user-only.ldif
```


cd terraform/


terraform apply

```bash
docker exec -it my-openldap-server ldapsearch -x -H ldap://localhost:389 -D "uid=svc-database,ou=users,dc=example,dc=org" -w "RETRIEVE NEW PASS" -b "uid=svc-database,ou=users,dc=example,dc=org" "(objectClass=*)"
```


sample for login ldap command:
```bash
docker exec my-openldap-server ldapwhoami -x -H ldap://localhost   -D "uid=svc-database,ou=Hashicorp,dc=example,dc=org"   -w "PASSWORD_SVC_DATABASE"
```


get from api
curl -s --header "X-Vault-Token: YOUR_TOKEN" https://127.0.0.1:8200/v1/ldap/static-cred/app-ldap-role --insecure



SYNC DB:

$env:db_pass = "YOUR_SA_DB_PASSWORD"

Get Password from Vault:
$jsonOutput = & curl.exe -s -k --header "X-Vault-Token: YOUR_VAULT_TOKEN" "https://127.0.0.1:8200/v1/ldap/static-cred/app-ldap-role"

($jsonOutput | ConvertFrom-Json).data.password 

RUN SCRIPT:
.\sync-credential.ps1 


