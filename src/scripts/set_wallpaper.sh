#!/bin/bash

# Comprueba si el usuario tiene un directorio de inicio
if [ -d "$HOME" ]; then
    # Establece el fondo de pantalla para el usuario
    gsettings set org.gnome.desktop.background picture-uri file:///usr/share/backgrounds/doncom_banner.jpg
fi
