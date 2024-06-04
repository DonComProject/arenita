#!/bin/bash

# Instalar avahi-daemon y avahi-utils
echo "Instalando avahi-daemon y avahi-utils..."
sudo apt-get install avahi-daemon avahi-utils -y

sudo systemctl restart avahi-daemon

env_file="/home/admin/doncom/.environment"
env_dir=$(dirname "$env_file")
if [ ! -d "$env_dir" ]; then
    mkdir -p "$env_dir"
fi

# Verificar si el archivo de entorno existe, si no, crearlo
if [ ! -f "$env_file" ]; then
    touch "$env_file"
fi

# Buscar servicios LDAP disponibles y resolver sus direcciones
services=$(avahi-browse -r _ldap._tcp --terminate)

# Procesar la salida de avahi-browse para obtener solo direcciones IPv4
ipv4_address=""
while IFS= read -r line; do
    if [[ $line =~ address\ =\ \[(.*)\] ]]; then
        ip=${BASH_REMATCH[1]}
        if [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            ipv4_address=$ip
            break
        fi
    fi
done <<< "$services"

if [ -n "$ipv4_address" ]; then
    # Agregar o actualizar la variable de entorno en el archivo
    echo "$ipv4_address" > $env_file

    echo "LDAP Server found with IPv4 address $ipv4_address"
else
    echo "No LDAP Server with IPv4 address found."
    exit 1
fi

# Comprobar si la variable de entorno IP_SERVER_LDAP está definida
if [ -z "$IP_SERVER_LDAP" ]; then
    echo "La variable de entorno IP_SERVER_LDAP no está definida."
    exit 1
fi

# Comprobar si el archivo de entorno existe y es legible
if [ ! -r "$env_file" ]; then
    echo "No se puede leer el archivo de entorno: $env_file"
    exit 1
fi

# Leer la dirección IP del servidor LDAP del archivo de entorno
IP_SERVER_LDAP=$(<"$env_file")

# Comprobar si la variable de entorno IP_SERVER_LDAP está definida
if [ -z "$IP_SERVER_LDAP" ]; then
    echo "La variable de entorno IP_SERVER_LDAP no está definida en $env_file."
    exit 1
fi

# Configurar debconf de manera no interactiva
echo "slapd slapd/password1 password davidtomas" | sudo debconf-set-selections
echo "slapd slapd/password2 password davidtomas" | sudo debconf-set-selections
echo "slapd slapd/internal/adminpw password davidtomas" | sudo debconf-set-selections
echo "slapd slapd/internal/generated_adminpw password davidtomas" | sudo debconf-set-selections
echo "slapd slapd/internal/adminpw_again password davidtomas" | sudo debconf-set-selections
echo "slapd slapd/password_mismatch note" | sudo debconf-set-selections
echo "slapd slapd/domain string doncom.com" | sudo debconf-set-selections
echo "slapd shared/organization string DonCom Organization" | sudo debconf-set-selections
echo "slapd slapd/backend string MDB" | sudo debconf-set-selections
echo "slapd slapd/purge_database boolean false" | sudo debconf-set-selections
echo "slapd slapd/move_old_database boolean true" | sudo debconf-set-selections

# Actualizar la configuración de ldap.conf con la dirección IP del servidor LDAP
echo "uri ldap://$IP_SERVER_LDAP" | sudo tee /etc/ldap/ldap.conf > /dev/null

# Actualizar la configuración de nslcd.conf con la dirección IP del servidor LDAP
echo "uri ldap://$IP_SERVER_LDAP" | sudo tee /etc/nslcd.conf > /dev/null

# Instalar los paquetes slapd y ldap-utils de forma no interactiva
sudo apt install slapd ldap-utils -y

# Editar /etc/pam.d/common-auth para añadir las configuraciones necesarias
COMMON_AUTH="/etc/pam.d/common-auth"

# Instalar los paquetes libpam-ldapd y libnss-ldapd de forma no interactiva
sudo DEBIAN_FRONTEND=noninteractive apt install libpam-ldapd libnss-ldapd -y

# Reiniciar el servicio nslcd
sudo systemctl restart nslcd

# Comprobar si 'Create home directory on login' está activado, y si no, activarlo
if ! sudo pam-auth-update --package | grep -q "Create home directory on login"; then
    sudo pam-auth-update --enable mkhomedir
fi

# Editar /etc/pam.d/common-auth para añadir las configuraciones necesarias
COMMON_AUTH="/etc/pam.d/common-auth"

if ! grep -q "pam_ldap.so minimum_uid=1000" $COMMON_AUTH; then
    sudo sed -i '/^auth\s\+requisite\s\+pam_deny.so/i auth    [success=1 default=ignore]  pam_ldap.so minimum_uid=1000' $COMMON_AUTH
fi

if ! grep -q "pam_deny.so" $COMMON_AUTH; then
    echo "auth    requisite           pam_deny.so" | sudo tee -a $COMMON_AUTH
fi

if ! grep -q "pam_permit.so" $COMMON_AUTH; then
    echo "auth    required            pam_permit.so" | sudo tee -a $COMMON_AUTH
fi

# Editar /etc/nsswitch.conf para añadir 'ldap' en las configuraciones de passwd, group y shadow
NSSWITCH_CONF="/etc/nsswitch.conf"

sudo sed -i '/^passwd:/ s/$/ ldap/' $NSSWITCH_CONF
sudo sed -i '/^group:/ s/$/ ldap/' $NSSWITCH_CONF
sudo sed -i '/^shadow:/ s/$/ ldap/' $NSSWITCH_CONF

# Añadir la línea en /etc/pam.d/common-session para crear el directorio home en el login
COMMON_SESSION="/etc/pam.d/common-session"
if ! grep -q "pam_mkhomedir.so" $COMMON_SESSION; then
    echo "session required pam_mkhomedir.so skel=/etc/skel/ umask=0022" | sudo tee -a $COMMON_SESSION
fi

echo "Configuración completada."

sudo systemctl restart nslcd
