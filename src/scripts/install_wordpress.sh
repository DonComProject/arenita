#!/bin/bash

# Función para imprimir mensajes en color
print_message() {
    # Colores de texto
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    BLUE='\033[0;34m'
    NC='\033[0m' # No color

    # Parámetros: $1 = mensaje, $2 = color
    echo -e "${2}${1}${NC}"
}

# Actualizar la lista de paquetes
print_message "Actualizando la lista de paquetes..." "$BLUE"
sudo apt-get update

# Descargar el playbook de Ansible
print_message "Descargando el playbook de Ansible..." "$BLUE"
wget https://raw.githubusercontent.com/DonComProject/arenita/main/src/ansible/wordpress.yml

# Instalar Ansible y otras dependencias necesarias
print_message "Instalando Ansible y otras dependencias..." "$BLUE"
sudo apt-get install -y ansible sshpass python3-pip

# Generar una clave SSH sin interacción y sobrescribir si ya existe
print_message "Generando clave SSH..." "$BLUE"
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N "" -q <<< y

# Copiar la clave pública al host local
print_message "Copiando la clave pública al host local..." "$BLUE"
ssh-copy-id -f -i ~/.ssh/id_rsa.pub usuario@$(hostname -I | cut -d ' ' -f1)

# Actualizar Ansible con pip
print_message "Actualizando Ansible con pip..." "$BLUE"
pip install --upgrade ansible

# Instalar la colección community.mysql
print_message "Instalando la colección community.mysql..." "$BLUE"
sudo ansible-galaxy collection install community.mysql

# Crear la carpeta /etc/ansible si no existe
print_message "Creando la carpeta /etc/ansible si no existe..." "$BLUE"
if [ ! -d /etc/ansible ]; then
  sudo mkdir -p /etc/ansible
fi

# Crear archivo hosts si no existe
print_message "Creando archivo hosts si no existe..." "$BLUE"
if [ ! -f /etc/ansible/hosts ]; then
  sudo touch /etc/ansible/hosts
fi

# Añadir al final del archivo hosts el siguiente contenido:
# [clientes]
# (y añadir la ip de la maquina que estoy usando el script ahora mismo)
print_message "Añadiendo dirección IP al archivo hosts..." "$BLUE"
echo "[clientes]" | sudo tee -a /etc/ansible/hosts
echo "$(hostname -I | cut -d ' ' -f1)" | sudo tee -a /etc/ansible/hosts

# Crear archivo ansible.cfg si no existe
print_message "Creando archivo ansible.cfg si no existe..." "$BLUE"
if [ ! -f /etc/ansible/ansible.cfg ]; then
  sudo touch /etc/ansible/ansible.cfg
fi

# Añadir configuración para deshabilitar la comprobación de la clave de host
print_message "Configurando Ansible para deshabilitar la comprobación de clave de host..." "$BLUE"
echo "[defaults]" | sudo tee -a /etc/ansible/ansible.cfg
echo "host_key_checking = False" | sudo tee -a /etc/ansible/ansible.cfg

# Ejecutar el playbook de Ansible
print_message "Ejecutando el playbook de Ansible..." "$BLUE"
sudo ansible-playbook hammad_wordpress.yml -k -b -K
