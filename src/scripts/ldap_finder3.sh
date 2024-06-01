#!/bin/bash

# DISCLAIMER
# DISCLAIMER
# DISCLAIMER
# DISCLAIMER
# DISCLAIMER
# DISCLAIMER
# DISCLAIMER
# EL 1 FUNCIONA EH, PERO ES QUE ESTE ES UN TESTTT
env_file="/home/admin/doncom/.environment"
env_dir=$(dirname "$env_file")
if [ ! -d "$env_dir" ]; then
    mkdir -p "$env_dir"
fi

# Verificar si el archivo de entorno existe, si no, crearlo
if [ ! -f "$env_file" ]; then
    touch "$env_file"
fi

# Ruta del archivo que contendrá las variables de entorno

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
