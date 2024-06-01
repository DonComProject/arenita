#!/bin/bash
sudo apt-get update

# Función para imprimir en color
print_in_color() {
    local color=$1
    local message=$2
    echo -e "\e[${color}m${message}\e[0m"
}

# Función para imprimir líneas de almohadilla
print_hashes() {
    local color=$1
    local message=$2
    print_in_color $color "##############################################"
    print_in_color $color "# $message #"
    print_in_color $color "##############################################"
}

# Colores
RED="31"
GREEN="32"
YELLOW="33"
BLUE="34"
MAGENTA="35"
CYAN="36"
WHITE="37"

# Directorio de trabajo
WORK_DIR=~/doncom/ldap

# Crear el directorio de trabajo si no existe
mkdir -p $WORK_DIR

# Cambiar al directorio de trabajo
cd $WORK_DIR

# Configurar debconf para evitar la interacción durante la instalación
print_hashes $CYAN "Configurando debconf para evitar interacción..."
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
print_hashes $GREEN "Estableciendo el frontend de debconf a no interactivo..."
export DEBIAN_FRONTEND=noninteractive

# Actualizar la lista de paquetes
print_hashes $YELLOW "Actualizando la lista de paquetes..."
sudo apt update

# Instalar net-tools
print_hashes $BLUE "Instalando net-tools..."
sudo apt install net-tools -y

# Instalar slapd y ldap-utils
print_hashes $MAGENTA "Instalando slapd y ldap-utils..."
sudo DEBIAN_FRONTEND=noninteractive apt install slapd ldap-utils -y

# Verificar el estado del servicio slapd
print_hashes $RED "Verificando el estado del servicio slapd..."
sudo systemctl status slapd --no-pager

# Verificar los puertos en los que slapd está escuchando
print_hashes $CYAN "Verificando los puertos en los que slapd está escuchando..."
sudo netstat -tulnp | grep slapd

# Realizar una consulta LDAP simple para verificar el funcionamiento
print_hashes $GREEN "Realizando una consulta LDAP simple para verificar el funcionamiento..."
ldapsearch -x -H ldap://localhost -b dc=doncom,dc=com

# Crear un archivo LDIF para el usuario admin
print_hashes $YELLOW "Creando un archivo LDIF para el usuario admin..."
cat <<EOF > admin.ldif
dn: cn=admin,dc=doncom,dc=com
objectClass: simpleSecurityObject
objectClass: organizationalRole
cn: admin
description: LDAP administrator
userPassword: $(slappasswd -s davidtomas)
EOF

# Añadir el usuario admin al LDAP
print_hashes $BLUE "Añadiendo el usuario admin al LDAP..."
ldapadd -x -D "cn=admin,dc=doncom,dc=com" -w davidtomas -f admin.ldif
rm admin.ldif 

# Crear un archivo LDIF para la unidad organizativa users
print_hashes $MAGENTA "Creando un archivo LDIF para la unidad organizativa users..."
cat <<EOF > ou_users.ldif
dn: ou=users,dc=doncom,dc=com
objectClass: organizationalUnit
ou: users
EOF

# Añadir la unidad organizativa users al LDAP
print_hashes $CYAN "Añadiendo la unidad organizativa users al LDAP..."
ldapadd -x -D "cn=admin,dc=doncom,dc=com" -w davidtomas -f ou_users.ldif
rm ou_users.ldif

# Instalar OpenJDK, una implementación de código abierto de la plataforma Java.
print_hashes $GREEN "Añadiendo una implementación de código abierto de Java..."
sudo apt install default-jdk -y

# Descargar Apache Directory Studio
print_hashes $RED "Descargando Apache Directory Studio..."
wget https://dlcdn.apache.org/directory/studio/2.0.0.v20210717-M17/ApacheDirectoryStudio-2.0.0.v20210717-M17-linux.gtk.x86_64.tar.gz

# Descomprimir el archivo descargado
print_hashes $YELLOW "Descomprimiendo el archivo descargado..."
tar -xzvf ApacheDirectoryStudio-2.0.0.v20210717-M17-linux.gtk.x86_64.tar.gz
rm ApacheDirectoryStudio-2.0.0.v20210717-M17-linux.gtk.x86_64.tar.gz

sudo apt-get install avahi-daemon avahi-utils -y
if [ ! -d "/etc/avahi/services" ]; then
    sudo mkdir -p /etc/avahi/services
fi

sudo tee /etc/avahi/services/ldap.service > /dev/null <<EOF
<?xml version="1.0" standalone='no'?>
<!DOCTYPE service-group SYSTEM "avahi-service.dtd">
<service-group>
    <name replace-wildcards="yes">LDAP Server</name>
    <service>
        <type>_ldap._tcp</type>
        <port>389</port>
    </service>
</service-group>
EOF

sudo systemctl restart avahi-daemon
