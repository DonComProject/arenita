#!/bin/bash

# Configurar debconf para evitar la interacción durante la instalación
echo "slapd slapd/password1 password davidtomas" | sudo debconf-set-selections
echo "slapd slapd/password2 password davidtomas" | sudo debconf-set-selections
echo "slapd slapd/domain string doncom.com" | sudo debconf-set-selections
echo "slapd shared/organization string DonComOrg" | sudo debconf-set-selections
echo "slapd slapd/no_configuration boolean false" | sudo debconf-set-selections
echo "slapd slapd/move_old_database boolean true" | sudo debconf-set-selections
echo "slapd slapd/allow_ldap_v2 boolean false" | sudo debconf-set-selections
echo "slapd slapd/purge_database boolean true" | sudo debconf-set-selections
echo "slapd slapd/dump_database select when needed" | sudo debconf-set-selections

# Establecer el frontend de debconf a no interactivo
export DEBIAN_FRONTEND=noninteractive

# Actualizar la lista de paquetes
sudo apt update

# Instalar net-tools
sudo apt install net-tools -y

# Instalar slapd y ldap-utils
sudo DEBIAN_FRONTEND=noninteractive apt install slapd ldap-utils -y

# Verificar el estado del servicio slapd
sudo systemctl status slapd

# Verificar los puertos en los que slapd está escuchando
sudo netstat -tulnp | grep slapd

# Realizar una consulta LDAP simple para verificar el funcionamiento
ldapsearch -x -H ldap://localhost -b dc=doncom,dc=com

# Crear un archivo LDIF para el usuario admin
cat <<EOF > admin.ldif
dn: cn=admin,dc=doncom,dc=com
objectClass: simpleSecurityObject
objectClass: organizationalRole
cn: admin
description: LDAP administrator
userPassword: $(slappasswd -s davidtomas)
EOF

# Añadir el usuario admin al LDAP
ldapadd -x -D "cn=admin,dc=doncom,dc=com" -w davidtomas -f admin.ldif
