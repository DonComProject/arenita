#!/bin/bash

# Ruta del archivo que contendrá las variables de entorno
env_file="/etc/profile.d/ldap_server.sh"

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
    # Guardar la variable de entorno en un archivo
    echo "export IP_SERVER_LDAP=$ipv4_address" > $env_file

    # Aplicar la variable de entorno inmediatamente para la sesión actual
    export IP_SERVER_LDAP=$ipv4_address

    echo "LDAP Server found with IPv4 address $ipv4_address"
else
    echo "No LDAP Server with IPv4 address found."
    exit 1
fi
