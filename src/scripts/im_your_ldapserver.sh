#!/bin/bash

# Actualizar la lista de paquetes
sudo apt-get update

# Instalar Avahi y utilidades
sudo apt-get install avahi-daemon avahi-utils -y

# Verificar si el directorio /etc/avahi/service existe, si no existe, crearlo
if [ ! -d "/etc/avahi/services" ]; then
    sudo mkdir -p /etc/avahi/services
fi

# Añadir el contenido al archivo /etc/avahi/services/ldap.service
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

# Reiniciar el servicio avahi-daemon
sudo systemctl restart avahi-daemon
