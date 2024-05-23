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

    # Mover la carpeta '[BOOT]'
    move_boot_directory(version_dir)

    # Modificar grub.cfg
    source_files_dir = os.path.join(version_dir, "source-files")
    modify_grub_file(source_files_dir)

    # Crear directorio server
    server_dir = create_server_directory(source_files_dir)

    # Seleccionar configuración de instalación automática
    choice = input("Selecciona una opción:\n1 - File Auto\n2 - File Personalized\n")
    if choice == '1':
        create_auto_install_file(server_dir)
    elif choice == '2':
        create_personalized_install_file(server_dir)
    else:
        print(f"{COLOR_YELLOW}Opción no válida. Saliendo del programa.{COLOR_RESET}")
        sys.exit(1)

    # Copiar user-data a meta-data
    create_meta_data_file(server_dir)

    # Crear la ISO final
    iso_name = f"ubuntu-22.04-{datetime.datetime.now().strftime('%Y-%m-%d_%H-%M-%S')}"
    build_iso(source_files_dir, iso_name)

    print(f"{COLOR_GREEN}Proceso completado.{COLOR_RESET}")

if __name__ == "__main__":
    main()


