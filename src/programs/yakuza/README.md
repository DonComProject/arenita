# Yakuza ISO Automation Script

## Overview
This script automates the process of downloading an Ubuntu ISO, modifying its contents, and creating a customized installation ISO. It ensures all necessary directories are created, required tools are installed, and the user is guided through necessary configurations.

## Table of Contents
- [Installation](#installation)
- [Usage](#usage)
- [Functions](#functions)
  - [create_yakuza_directory](#create_yakuza_directory)
  - [create_config_directory](#create_config_directory)
  - [download_iso](#download_iso)
  - [check_7z_installed](#check_7z_installed)
  - [create_yakuza_version_directory](#create_yakuza_version_directory)
  - [extract_iso](#extract_iso)
  - [modify_grub_file](#modify_grub_file)
  - [create_server_directory](#create_server_directory)
  - [create_auto_install_file](#create_auto_install_file)
  - [create_personalized_install_file](#create_personalized_install_file)
  - [create_meta_data_file](#create_meta_data_file)
  - [move_boot_directory](#move_boot_directory)
  - [build_iso](#build_iso)

## Installation
### Prerequisites
Ensure you have the following installed:
- Python 3.x
- wget
- 7z (7-Zip)
- xorriso
- openssl

### Installation Steps
1. Clone the repository:
    ```sh
    git clone https://github.com/yourusername/yakuza-iso-automation.git
    cd yakuza-iso-automation
    ```

2. Ensure all dependencies are installed:
    ```sh
    sudo apt update
    sudo apt install wget p7zip-full xorriso openssl
    ```

## Usage
Run the script with:
```sh
python3 main.py
```

Follow the prompts to complete the setup and generate your custom Ubuntu ISO.

## Functions

| Function | Description |
| --- | --- |
| `create_yakuza_directory` | Creates the `~/yakuza` directory if it doesn't exist. |
| `create_config_directory` | Creates the `.config` directory inside `yakuza`. |
| `download_iso` | Downloads the Ubuntu ISO if it doesn't already exist. |
| `check_7z_installed` | Checks if 7z is installed, exits if not. |
| `create_yakuza_version_directory` | Creates a versioned directory inside `yakuza`. |
| `extract_iso` | Extracts the ISO contents using 7z. |
| `modify_grub_file` | Modifies the `grub.cfg` file to add a custom menu entry. |
| `create_server_directory` | Creates a `server` directory inside the extracted ISO files. |
| `create_auto_install_file` | Creates an automatic installation configuration file. |
| `create_personalized_install_file` | Creates a personalized installation configuration file. |
| `create_meta_data_file` | Copies the contents of `user-data` to `meta-data`. |
| `move_boot_directory` | Moves the `[BOOT]` directory to a new location. |
| `build_iso` | Builds a new ISO from the modified files. |

---

# Script de Automatización de ISO de Yakuza

## Resumen
Este script automatiza el proceso de descarga de un ISO de Ubuntu, modificación de su contenido y creación de un ISO de instalación personalizado. Asegura que todos los directorios necesarios se creen, que las herramientas requeridas se instalen y guía al usuario a través de las configuraciones necesarias.

## Tabla de Contenidos
- [Instalación](#instalación)
- [Uso](#uso)
- [Funciones](#funciones)
  - [create_yakuza_directory](#create_yakuza_directory)
  - [create_config_directory](#create_config_directory)
  - [download_iso](#download_iso)
  - [check_7z_installed](#check_7z_installed)
  - [create_yakuza_version_directory](#create_yakuza_version_directory)
  - [extract_iso](#extract_iso)
  - [modify_grub_file](#modify_grub_file)
  - [create_server_directory](#create_server_directory)
  - [create_auto_install_file](#create_auto_install_file)
  - [create_personalized_install_file](#create_personalized_install_file)
  - [create_meta_data_file](#create_meta_data_file)
  - [move_boot_directory](#move_boot_directory)
  - [build_iso](#build_iso)

## Instalación
### Prerrequisitos
Asegúrate de tener lo siguiente instalado:
- Python 3.x
- wget
- 7z (7-Zip)
- xorriso
- openssl

### Pasos de Instalación
1. Clona el repositorio:
    ```sh
    git clone https://github.com/yourusername/yakuza-iso-automation.git
    cd yakuza-iso-automation
    ```

2. Asegúrate de que todas las dependencias estén instaladas:
    ```sh
    sudo apt update
    sudo apt install wget p7zip-full xorriso openssl
    ```

## Uso
Ejecuta el script con:
```sh
python3 main.py
```

Sigue las indicaciones para completar la configuración y generar tu ISO de Ubuntu personalizado.

## Funciones

| Función | Descripción |
| --- | --- |
| `create_yakuza_directory` | Crea el directorio `~/yakuza` si no existe. |
| `create_config_directory` | Crea el directorio `.config` dentro de `yakuza`. |
| `download_iso` | Descarga el ISO de Ubuntu si no existe. |
| `check_7z_installed` | Verifica si 7z está instalado, si no, sale del script. |
| `create_yakuza_version_directory` | Crea un directorio versionado dentro de `yakuza`. |
| `extract_iso` | Extrae el contenido del ISO usando 7z. |
| `modify_grub_file` | Modifica el archivo `grub.cfg` para agregar una entrada de menú personalizada. |
| `create_server_directory` | Crea un directorio `server` dentro de los archivos extraídos del ISO. |
| `create_auto_install_file` | Crea un archivo de configuración de instalación automática. |
| `create_personalized_install_file` | Crea un archivo de configuración de instalación personalizada. |
| `create_meta_data_file` | Copia el contenido de `user-data` a `meta-data`. |
| `move_boot_directory` | Mueve el directorio `[BOOT]` a una nueva ubicación. |
| `build_iso` | Construye un nuevo ISO a partir de los archivos modificados. |

---

Enjoy creating your custom Ubuntu ISO with Yakuza ISO Automation Script!

¡Disfruta creando tu ISO personalizado de Ubuntu con el Script de Automatización de ISO de Yakuza!
