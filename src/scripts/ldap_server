#!/bin/bash
sudo apt update && sudo apt install slapd ldap-utils -y
# Añadimos password...

sudo dpkg-reconfigure slapd
# Omitir configuración del servidor OpenLDAP --> <No>
# Introducir el nombre del dominio DNS --> doncom.com
# Nombre de la organización --> DonCom Organization
# Contraseña del administrador --> password
# Confirmar contraseña --> password
# Desea que se borre la base de datos cuando se purgue el paquete slapd --> <No>
# ¿Desea mover la base de datos antigua? --> <Si>

ldapsearch -x -LLL -H ldap://localhost -D "cn=admin,dc=doncom,dc=com" -W -b "dc=doncom,dc=com"
# Contenido de admin.ldif
# dn: cn=admin,dc=doncom,dc=com
# objectClass: organizationalRole
# cn: admin
# description: LDAP administrator
ldapadd -x -D "cn=admin,dc=doncom,dc=com" -W -f admin.ldif

wget https://raw.githubusercontent.com/DonComProject/arenita/main/src/ldif/ldap_structure.ldif
ldapadd -x -D cn=admin,dc=doncom,dc=com -W -f ldap_structure.ldif
