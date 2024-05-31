#!/bin/bash

# Comprobar si la variable de entorno IP_SERVER_LDAP está definida
if [ -z "$IP_SERVER_LDAP" ]; then
    echo "La variable de entorno IP_SERVER_LDAP no está definida."
    exit 1
fi

# Buscar el servidor LDAP
LDAP_SERVER=$IP_SERVER_LDAP
LDAP_BASE_DN="dc=doncom,dc=com"
LDAP_PASSWORD="davidtomas"

# Configurar debconf para una instalación no interactiva de libpam-ldapd y libnss-ldapd
sudo debconf-set-selections <<EOF
libnss-ldapd libnss-ldapd/nsswitch multiselect passwd, group, shadow, hosts
libpam-ldapd libpam-ldapd/dblogin boolean false
libpam-ldapd libpam-ldapd/ldapns/base-dn string $LDAP_BASE_DN
libpam-ldapd libpam-ldapd/ldapns/ldap-server string ldap://$LDAP_SERVER
libpam-ldapd libpam-ldapd/ldapns/ldap_version select 3
libpam-ldapd libpam-ldapd/ldapns/ldap-port string 389
libpam-ldapd shared/ldapns/ldap-server string ldap://$LDAP_SERVER
libpam-ldapd libpam-ldapd/ldapns/ldap-base-dn string $LDAP_BASE_DN
libpam-ldapd shared/ldapns/base-dn string $LDAP_BASE_DN
libpam-ldapd libpam-ldapd/ldapns/ldap-binddn string cn=admin,$LDAP_BASE_DN
libpam-ldapd libpam-ldapd/ldapns/ldap-bindpw password $LDAP_PASSWORD
EOF


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
