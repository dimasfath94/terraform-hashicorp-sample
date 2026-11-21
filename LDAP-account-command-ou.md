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
  | awk -F': ' '
    /^dn: / {
      # Ganti bagian setelah uid=svc-database, menjadi ou=Hashicorp,dc=example,dc=org
      sub(/^uid=[^,]+,/, "uid=svc-database,", $2)
      # Jika DN lama tidak diawali uid=, paksa ke uid=svc-database,ou=Hashicorp,dc=example,dc=org
      print "dn: uid=svc-database,ou=Hashicorp,dc=example,dc=org"
      next
    }
    NF > 0 { print }
  ' \
  | docker exec -i my-openldap-server ldapadd -x -H ldap://localhost \
      -D "cn=admin,dc=example,dc=org" -w admin
