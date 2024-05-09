#!/bin/bash
# Verifica si se proporciona un argumento.
# Obtiene el nuevo nombre del host del primer argumento.
# Cambia el nombre del host.
# Muestra mensaje de confirmación.
# Preguntar al usuario si desea reiniciar.
# Verificar la respuesta del usuario y ejecuta una orden segun la respuesta.
if [ $# -ne 1 ]; then
    echo "Uso: $0 <nuevo_nombre>"
    exit 1
fi

nuevo_nombre=$1


echo "$nuevo_nombre" | sudo tee /etc/hostname > /dev/null

echo "Nombre del host cambiado a $nuevo_nombre"


read -p "¿Desea reiniciar el sistema ahora? (1: Sí, 0: No): " reiniciar


case $reiniciar in
    1)
        echo "Reiniciando el sistema..."
        sudo reboot
        ;;
    0)
        echo "No se reiniciará el sistema."
        ;;
    *)
        echo "Respuesta no válida. No se reiniciará el sistema."
        ;;
esac
