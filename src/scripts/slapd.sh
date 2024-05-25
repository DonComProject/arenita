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
print_in_color $CYAN "# Configurando debconf para evitar interacción... #"
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
print_in_color $GREEN "# Estableciendo el frontend de debconf a no interactivo... #"
print_in_color $GREEN "##############################################"
export DEBIAN_FRONTEND=noninteractive

# Actualizar la lista de paquetes
print_in_color $YELLOW "##############################################"
print_in_color $YELLOW "# Actualizando la lista de paquetes... #"
print_in_color $YELLOW "##############################################"
sudo apt update

# Instalar net-tools
print_in_color $BLUE "##############################################"
print_in_color $BLUE "# Instalando net-tools... #"
print_in_color $BLUE "##############################################"
sudo apt install net-tools -y

# Instalar slapd y ldap-utils
print_in_color $MAGENTA "##############################################"
print_in_color $MAGENTA "# Instalando slapd y ldap-utils... #"
print_in_color $MAGENTA "##############################################"
sudo DEBIAN_FRONTEND=noninteractive apt install slapd ldap-utils -y

# Verificar el estado del servicio slapd
print_in_color $RED "##############################################"
print_in_color $RED "# Verificando el estado del servicio slapd... #"
print_in_color $RED "##############################################"
sudo systemctl status slapd

# Verificar los puertos en los que slapd está escuchando
print_in_color $CYAN "##############################################"
print_in_color $CYAN "# Verificando los puertos en los que slapd está escuchando... #"
print_in_color $CYAN "##############################################"
sudo netstat -tulnp | grep slapd

# Realizar una consulta LDAP simple para verificar el funcionamiento
print_in_color $GREEN "##############################################"
print_in_color $GREEN "# Realizando una consulta LDAP simple para verificar el funcionamiento... #"
print_in_color $GREEN "##############################################"
ldapsearch -x -H ldap://localhost -b dc=doncom,dc=com

# Crear un archivo LDIF para el usuario admin
print_in_color $YELLOW "##############################################"
print_in_color $YELLOW "# Creando un archivo LDIF para el usuario admin... #"
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
print_in_color $BLUE "# Añadiendo el usuario admin al LDAP... #"
print_in_color $BLUE "##############################################"
ldapadd -x -D "cn=admin,dc=doncom,dc=com" -w davidtomas -f admin.ldif

# Crear un archivo LDIF para la unidad organizativa users
print_in_color $MAGENTA "##############################################"
print_in_color $MAGENTA "# Creando un archivo LDIF para la unidad organizativa users... #"
print_in_color $MAGENTA "##############################################"
cat <<EOF > ou_users.ldif
dn: ou=users,dc=doncom,dc=com
objectClass: organizationalUnit
ou: users
EOF

# Añadir la unidad organizativa users al LDAP
print_in_color $CYAN "##############################################"
print_in_color $CYAN "# Añadiendo la unidad organizativa users al LDAP... #"
print_in_color $CYAN "##############################################"
ldapadd -x -D "cn=admin,dc=doncom,dc=com" -w davidtomas -f ou_users.ldif


#Instalar OpenJDK, una implementación de código abierto de la plataforma Java.
print_in_color $GREEN "##############################################"
print_in_color $GREEN "# Añadiendo una implementación de código abierto de Java... #"
print_in_color $GREEN "##############################################"
sudo apt install default-jdk

# Descargar Apache Directory Studio
print_in_color $RED "##############################################"
print_in_color $RED "# Descargando Apache Directory Studio... #"
print_in_color $RED "##############################################"
wget https://dlcdn.apache.org/directory/studio/2.0.0.v20210717-M17/ApacheDirectoryStudio-2.0.0.v20210717-M17-linux.gtk.x86_64.tar.gz

# Descomprimir el archivo descargado
print_in_color $YELLOW "##############################################"
print_in_color $YELLOW "# Descomprimiendo el archivo descargado... #"
print_in_color $YELLOW "##############################################"
tar -xzvf ApacheDirectoryStudio-2.0.0.v20210717-M17-linux.gtk.x86_64.tar.gz

# Descargar y ejecutar el script rocket_setup.sh desde el repositorio Rocket en GitHub
print_in_color $MAGENTA "##############################################"
print_in_color $MAGENTA "# Descargando y ejecutando el script rocket_setup.sh desde el repositorio Rocket en GitHub... #"
print_in_color $MAGENTA "##############################################"
git clone https://github.com/DonComProject/rocket
cd rocket
bash rocket_setup.sh
