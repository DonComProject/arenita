# yakuza.py

from defs import *
from imports import *

def main():
    print(f"{COLOR_YELLOW}Iniciando programa Yakuza...{COLOR_RESET}")

    # Crear directorio principal yakuza
    yakuza_dir = create_yakuza_directory()

    # Crear directorio .config dentro de yakuza y descargar ISO si no existe
    create_config_directory()
    download_iso()

    # Verificar si 7z está instalado
    check_7z_installed()

    # Crear directorio yakuza-diaHora-version
    version_dir = create_yakuza_version_directory(yakuza_dir)

    # Extraer ISO en el directorio creado
    extract_iso(version_dir)

    print(f"{COLOR_GREEN}Proceso completado.{COLOR_RESET}")

if __name__ == "__main__":
    main()
