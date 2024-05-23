#!/bin/bash

# Descargar el paquete de instalación de Veyon
wget https://github.com/DonComProject/arenita/raw/main/src/deb-files/veyon_4.8.3.0-ubuntu.jammy_amd64.deb

# Instalar Veyon usando dpkg
sudo dpkg -i veyon_4.8.3.0-ubuntu.jammy_amd64.deb

# Si hay dependencias no satisfechas, intenta corregirlas con
sudo apt-get -f install
