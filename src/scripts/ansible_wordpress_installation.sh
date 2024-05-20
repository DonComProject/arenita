#!/bin/bash

# Actualizar la lista de paquetes
sudo apt-get update

# Descargar el playbook de Ansible
wget https://raw.githubusercontent.com/DonComProject/arenita/main/src/ansible/hammad_wordpress.yml

# Instalar Ansible y otras dependencias necesarias
sudo apt-get install -y ansible sshpass python3-pip

# Generar una clave SSH sin interacción y sobrescribir si ya existe
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N "" -q <<< y

# Copiar la clave pública al host local
ssh-copy-id -f -i ~/.ssh/id_rsa.pub usuario@$(hostname -I | cut -d ' ' -f1)

# Actualizar Ansible con pip
pip install --upgrade ansible

# Instalar la colección community.mysql
sudo ansible-galaxy collection install community.mysql

# Crear la carpeta /etc/ansible si no existe
if [ ! -d /etc/ansible ]; then
  sudo mkdir -p /etc/ansible
fi

# Crear archivo hosts si no existe
if [ ! -f /etc/ansible/hosts ]; then
  sudo touch /etc/ansible/hosts
fi

# Añadir al final del archivo hosts el siguiente contenido:
# [clientes]
# (y añadir la ip de la maquina que estoy usando el script ahora mismo)
echo "[clientes]" | sudo tee -a /etc/ansible/hosts
echo "$(hostname -I | cut -d ' ' -f1)" | sudo tee -a /etc/ansible/hosts

# Ejecutar el playbook de Ansible
sudo ansible-playbook hammad_wordpress.yml -k -b -K
