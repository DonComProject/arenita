# AÑADIR UN USUARIO NUEVO
```shell
ldapadd -x -D cn=admin,dc=doncom,dc=com -W -f file.ldif
```

## REVISAR EL LISTADO DE ARCIVOS LDIF SUBIDOS
```shell
ldapserach -x -LLL -H ldap://localhost -D "cn=admin,dc=doncom,dc=com" -W -b "dc=doncom,dc=com"
```
