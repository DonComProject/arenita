#!/bin/bash

# Verificar si se pasaron los argumentos necesarios (condicional)
if [ "$#" -ne 3 ]; then
    echo "Uso: $0 <interfaz> <nueva_ip> <mascara>"
    echo "Ejemplo: $0 enp3s0 192.168.12.200/24"
    exit 1
fi

# Asignar los argumentos a variables
INTERFAZ=$1
NUEVA_IP=$2
MASCARA=$3

# Eliminar la IP actual (asumimos que hay una sola)
sudo ip addr flush dev $INTERFAZ

# Asignar la nueva IP con la máscara especificada
sudo ip addr add $NUEVA_IP/$MASCARA dev $INTERFAZ

# Subir la interfaz para aplicar los cambios
sudo ip link set dev $INTERFAZ up

# Mostrar la configuración de la interfaz
ip addr show dev $INTERFAZ

echo "La nueva IP $NUEVA_IP/$MASCARA ha sido asignada a la interfaz $INTERFAZ."
