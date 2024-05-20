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
sudo ssh-copy-id -i ~/.ssh/id_rsa.pub usuario@$(hostname -I | cut -d ' ' -f1)

# Actualizar Ansible con pip
pip install --upgrade ansible

# Instalar la colección community.mysql
sudo ansible-galaxy collection install community.mysql

# Ejecutar el playbook de Ansible
sudo ansible-playbook hammad_wordpress.yml -k -b -K
