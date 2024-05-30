#!/bin/bash

# Actualizar la lista de paquetes e instalar los paquetes necesarios
sudo apt update && sudo apt install libpam-ldapd libnss-ldapd ldap-utils -y

# Reiniciar el servicio nslcd
sudo systemctl restart nslcd

# Configurar PAM para LDAP
sudo pam-auth-update

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
