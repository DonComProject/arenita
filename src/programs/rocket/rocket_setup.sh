#!/bin/bash

# Instalar Python 3
sudo apt install python3 -y

# Establecer alias rocket
alias rocket="python3 $(pwd)/main.py"

# Establecer un alias para ejecutar el script main.py
echo 'alias rocket="python3 $(pwd)/main.py"' >> ~/.bashrc

# Actualizar el archivo .bashrc
source ~/.bashrc
