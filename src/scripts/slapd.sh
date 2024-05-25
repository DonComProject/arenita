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

# Actualizar la lista de paquetes e instalar slapd y ldap-utils
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install slapd ldap-utils -y
