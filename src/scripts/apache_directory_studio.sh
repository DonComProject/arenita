#!/bin/bash

# Descargar Apache Directory Studio
wget https://dlcdn.apache.org/directory/studio/2.0.0.v20210717-M17/ApacheDirectoryStudio-2.0.0.v20210717-M17-linux.gtk.x86_64.tar.gz

# Descomprimir el archivo descargado
tar -xzvf ApacheDirectoryStudio-2.0.0.v20210717-M17-linux.gtk.x86_64.tar.gz

# Cambiar al directorio del programa
cd ApacheDirectoryStudio

# Ejecutar Apache Directory Studio
./ApacheDirectoryStudio
