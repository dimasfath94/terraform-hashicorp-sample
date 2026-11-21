docker exec -i my-openldap-server ldapdelete -r -x -H ldap://localhost \
  -D "cn=admin,dc=example,dc=org" -w admin \
  "ou=Hashicorp,dc=example,dc=org"

  verification: 
  docker exec my-openldap-server ldapsearch -x -H ldap://localhost \
  -D "cn=admin,dc=example,dc=org" -w admin \
  -b "ou=Hashicorp,dc=example,dc=org"


  create ldap ou:
  # A. Create again ou=Hashicorp
docker exec -i my-openldap-server ldapadd -x -H ldap://localhost \
  -D "cn=admin,dc=example,dc=org" -w admin <<'EOF'
dn: ou=Hashicorp,dc=example,dc=org
objectClass: organizationalUnit
ou: Hashicorp
EOF

# B. Export existing entry svc-database, ubah parent DN ke ou=Hashicorp, lalu add ke OpenLDAP
docker exec my-openldap-server ldapsearch -LLL -x -H ldap://localhost \
  -D "cn=admin,dc=example,dc=org" -w admin \
  -b "dc=example,dc=org" "(uid=svc-database)" \
| tr -d '\r' \
| awk -F': ' '
  /^dn: / {
    dn = $2
    if (dn ~ /^uid=/) {
      sub(/,.*$/, ",ou=Hashicorp,dc=example,dc=org", dn)
    } else {
      dn = "uid=svc-database,ou=Hashicorp,dc=example,dc=org"
    }
    print "dn: " dn
    next
  }
  NF > 0 { print }
' \
| docker exec -i my-openldap-server ldapadd -x -H ldap://localhost \
  -D "cn=admin,dc=example,dc=org" -w admin






  #test login
  docker exec my-openldap-server ldapwhoami -x -H ldap://localhost \
  -D "uid=svc-database,ou=Hashicorp,dc=example,dc=org" \
  -w "PASSWORD_SVC_DATABASE"
