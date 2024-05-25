#!/bin/bash

# Función para imprimir en color
print_in_color() {
    local color=$1
    local message=$2
    echo -e "\e[${color}m${message}\e[0m"
}

# Colores
RED="31"
GREEN="32"
YELLOW="33"
BLUE="34"
MAGENTA="35"
CYAN="36"
WHITE="37"

# Configurar debconf para evitar la interacción durante la instalación
print_in_color $CYAN "##############################################"
print_in_color $CYAN "# Configurando debconf para evitar interacción, manín... #"
print_in_color $CYAN "##############################################"
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
print_in_color $GREEN "##############################################"
print_in_color $GREEN "# Estableciendo el frontend de debconf a no interactivo, manín... #"
print_in_color $GREEN "##############################################"
export DEBIAN_FRONTEND=noninteractive

# Actualizar la lista de paquetes
print_in_color $YELLOW "##############################################"
print_in_color $YELLOW "# Actualizando la lista de paquetes, manín... #"
print_in_color $YELLOW "##############################################"
sudo apt update

# Instalar net-tools
print_in_color $BLUE "##############################################"
print_in_color $BLUE "# Instalando net-tools, manín... #"
print_in_color $BLUE "##############################################"
sudo apt install net-tools -y

# Instalar slapd y ldap-utils
print_in_color $MAGENTA "##############################################"
print_in_color $MAGENTA "# Instalando slapd y ldap-utils, manín... #"
print_in_color $MAGENTA "##############################################"
sudo DEBIAN_FRONTEND=noninteractive apt install slapd ldap-utils -y

# Verificar el estado del servicio slapd
print_in_color $RED "##############################################"
print_in_color $RED "# Verificando el estado del servicio slapd, manín... #"
print_in_color $RED "##############################################"
sudo systemctl status slapd

# Verificar los puertos en los que slapd está escuchando
print_in_color $CYAN "##############################################"
print_in_color $CYAN "# Verificando los puertos en los que slapd está escuchando, manín... #"
print_in_color $CYAN "##############################################"
sudo netstat -tulnp | grep slapd

# Realizar una consulta LDAP simple para verificar el funcionamiento
print_in_color $GREEN "##############################################"
print_in_color $GREEN "# Realizando una consulta LDAP simple para verificar el funcionamiento, manín... #"
print_in_color $GREEN "##############################################"
ldapsearch -x -H ldap://localhost -b dc=doncom,dc=com

# Crear un archivo LDIF para el usuario admin
print_in_color $YELLOW "##############################################"
print_in_color $YELLOW "# Creando un archivo LDIF para el usuario admin, manín... #"
print_in_color $YELLOW "##############################################"
cat <<EOF > admin.ldif
dn: cn=admin,dc=doncom,dc=com
objectClass: simpleSecurityObject
objectClass: organizationalRole
cn: admin
description: LDAP administrator
userPassword: $(slappasswd -s davidtomas)
EOF

# Añadir el usuario admin al LDAP
print_in_color $BLUE "##############################################"
print_in_color $BLUE "# Añadiendo el usuario admin al LDAP, manín... #"
print_in_color $BLUE "##############################################"
ldapadd -x -D "cn=admin,dc=doncom,dc=com" -w davidtomas -f admin.ldif
