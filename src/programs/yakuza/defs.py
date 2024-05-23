from constants import *
from imports import *

def create_yakuza_directory():
    yakuza_dir = os.path.expanduser("~/yakuza")
    if not os.path.exists(yakuza_dir):
        os.makedirs(yakuza_dir)
        print(f"{COLOR_GREEN}Directorio 'yakuza' creado en el hogar del usuario.{COLOR_RESET}")
    return yakuza_dir

def create_config_directory():
    if not os.path.exists(CONFIG_DIR):
        os.makedirs(CONFIG_DIR)
        print(f"{COLOR_GREEN}Directorio '.config' creado dentro de 'yakuza'.{COLOR_RESET}")

def download_iso():
    if not os.path.exists(ISO_PATH):
        print(f"{COLOR_YELLOW}Descargando ISO...{COLOR_RESET}")
        subprocess.run(["wget", "-O", ISO_PATH, ISO_URL], check=True)
        print(f"{COLOR_GREEN}ISO descargado y almacenado en {ISO_PATH}.{COLOR_RESET}")
    else:
        print(f"{COLOR_GREEN}ISO ya descargado previamente en {ISO_PATH}.{COLOR_RESET}")

def check_7z_installed():
    try:
        subprocess.run(["7z"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        print(f"{COLOR_GREEN}7z está instalado.{COLOR_RESET}")
    except FileNotFoundError:
        print(f"{COLOR_YELLOW}7z no está instalado. Instálalo e inténtalo de nuevo.{COLOR_RESET}")
        sys.exit(1)

def create_yakuza_version_directory(yakuza_dir):
    now = datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    version_dir = os.path.join(yakuza_dir, f"yakuza-{now}-version")
    os.makedirs(version_dir)
    print(f"{COLOR_GREEN}Directorio '{version_dir}' creado.{COLOR_RESET}")
    return version_dir

def extract_iso(version_dir):
    source_files_dir = os.path.join(version_dir, "source-files")
    os.makedirs(source_files_dir)
    print(f"{COLOR_YELLOW}Extrayendo ISO en '{source_files_dir}'...{COLOR_RESET}")
    subprocess.run(["7z", "x", ISO_PATH, f"-o{source_files_dir}", "-y"], check=True)
    print(f"{COLOR_GREEN}ISO extraído en '{source_files_dir}'.{COLOR_RESET}")

def modify_grub_file(source_files_dir):
    grub_file_path = os.path.join(source_files_dir, "boot/grub/grub.cfg")
    with open(grub_file_path, 'r') as file:
        grub_content = file.readlines()

    for i in range(len(grub_content)):
        if "set menu_color_normal" in grub_content[i]:
            grub_content[i] = grub_content[i].replace("white", "yellow")
        if "set menu_color_highlight" in grub_content[i]:
            grub_content[i] = grub_content[i].replace("white", "yellow")

    new_menuentry = """menuentry "DonCom Ubuntu Server" {
        set gfxpayload=keep
        linux   /casper/vmlinuz quiet autoinstall ds=nocloud\\;s=/cdrom/server/ ---
        initrd  /casper/initrd
}\n"""
    for i in range(len(grub_content)):
        if grub_content[i].startswith("menuentry"):
            grub_content.insert(i, new_menuentry)
            break

    with open(grub_file_path, 'w') as file:
        file.writelines(grub_content)

    print(f"{COLOR_GREEN}Archivo 'grub.cfg' modificado correctamente.{COLOR_RESET}")

def create_server_directory(source_files_dir):
    server_dir = os.path.join(source_files_dir, "server")
    os.makedirs(server_dir)
    print(f"{COLOR_GREEN}Directorio 'server' creado en '{source_files_dir}'.{COLOR_RESET}")
    return server_dir

def create_auto_install_file(server_dir):
    config_content = """#cloud-config
autoinstall:
  version: 1
  identity:
    hostname: doncom
    username: admin
    password: $6$A8TPSoM/hhcc6jkv$5WAmDVk6JP0xj76DmeO711VC2grPZJAXmS88tiG13kowziCM1U0zZKNPkMhPv3HiSNV6c2JslSpsfA.UbmlQV1
  storage:
    layout:
      name: direct
  ssh:
    install-server: yes
  locale: es_ES.UTF-8
  keyboard: {layout: es, variant: ''}
  packages:
    - ubuntu-desktop
  user-data:
    packages:
    - dbus-x11
    runcmd:
     - wget https://github.com/DonComProject/arenita/raw/main/src/deb-files/veyon_4.8.3.0-ubuntu.jammy_amd64.deb -O /tmp/veyon.deb
     - dpkg -i /tmp/veyon.deb
     - apt-get install -f -y
     - wget https://raw.githubusercontent.com/DonComProject/arenita/main/img/doncom_banner.jpg -O /usr/share/backgrounds/doncom_banner.jpg
     - sudo -u admin dbus-launch gsettings set org.gnome.desktop.background picture-uri 'file:///usr/share/backgrounds/doncom_banner.jpg'
"""
    with open(os.path.join(server_dir, "user-data"), 'w') as file:
        file.write(config_content)

    print(f"{COLOR_GREEN}Archivo de configuración 'user-data' creado automáticamente.{COLOR_RESET}")

def create_personalized_install_file(server_dir):
    hostname = input("Introduce el hostname: ")
    username = input("Introduce el nombre de usuario: ")
    password = input("Introduce la contraseña: ")
    encrypted_password = subprocess.run(
        ["openssl", "passwd", "-6", password], capture_output=True, text=True).stdout.strip()

    config_content = f"""#cloud-config
autoinstall:
  version: 1
  identity:
    hostname: {hostname}
    username: {username}
    password: {encrypted_password}
  storage:
    layout:
      name: direct
  ssh:
    install-server: yes
  locale: es_ES.UTF-8
  keyboard: {{layout: es, variant: ''}}
  packages:
    - ubuntu-desktop
"""
    with open(os.path.join(server_dir, "user-data"), 'w') as file:
        file.write(config_content)

    print(f"{COLOR_GREEN}Archivo de configuración 'user-data' personalizado creado.{COLOR_RESET}")

"""def build_iso(version_dir, iso_name):
    source_files_dir = os.path.join(version_dir, "source-files")
    iso_output_path = os.path.join(version_dir, f"{iso_name}.iso")
    os.chdir(source_files_dir)
    subprocess.run([
        "xorriso", "-as", "mkisofs", "-r",
        "-V", "'Ubuntu 22.04 LTS AUTO (EFIBIOS)'",
        "-o", iso_output_path,
        "--grub2-mbr", "../BOOT/1-Boot-NoEmul.img",
        "-partition_offset", "16",
        "--mbr-force-bootable",
        "-append_partition", "2", "28732ac11ff8d211ba4b00a0c93ec93b", "../BOOT/2-Boot-NoEmul.img",
        "-appended_part_as_gpt",
        "-iso_mbr_part_type", "a2a0d0ebe5b9334487c068b6b72699c7",
        "-c", "/boot.catalog",
        "-b", "/boot/grub/i386-pc/eltorito.img",
        "-no-emul-boot", "-boot-load-size", "4", "-boot-info-table",
        "--grub2-boot-info",
        "-eltorito-alt-boot",
        "-e", "--interval:appended_partition_2:::",
        "-no-emul-boot", "."
    ], check=True)
    print(f"{COLOR_GREEN}ISO creada en '{iso_output_path}'.{COLOR_RESET}")"""

def move_boot_directory(version_dir):
    source_files_dir = os.path.join(version_dir, "source-files")
    boot_source = os.path.join(source_files_dir, "[BOOT]")
    boot_target = os.path.join(version_dir, "BOOT")
    if os.path.exists(boot_source):
        os.rename(boot_source, boot_target)
        print(f"{COLOR_GREEN}Carpeta '[BOOT]' movida a '{boot_target}'.{COLOR_RESET}")
    else:
        print(f"{COLOR_YELLOW}Carpeta '[BOOT]' no encontrada.{COLOR_RESET}")

"""def create_meta_data_file(server_dir):
    meta_data_path = os.path.join(server_dir, "meta-data")
    with open(meta_data_path, 'w') as file:
        file.write("")
    print(f"{COLOR_GREEN}Archivo 'meta-data' creado en '{server_dir}'.{COLOR_RESET}")

"""

def create_meta_data_file(server_dir):
    # Ruta al archivo user-data
    user_data_path = os.path.join(server_dir, "user-data")

    # Leer el contenido de user-data
    with open(user_data_path, 'r') as user_data_file:
        user_data_content = user_data_file.read()

    # Ruta al archivo meta-data
    meta_data_path = os.path.join(server_dir, "meta-data")

    # Escribir el contenido de user-data en meta-data
    with open(meta_data_path, 'w') as meta_data_file:
        meta_data_file.write(user_data_content)

    print(f"{COLOR_GREEN}Contenido de 'user-data' copiado a 'meta-data' en '{server_dir}'.{COLOR_RESET}")


def build_iso(source_files_dir, iso_name):
    iso_output_path = os.path.join(os.path.dirname(source_files_dir), f"{iso_name}.iso")
    boot_dir = os.path.join(os.path.dirname(source_files_dir), "BOOT")
    os.chdir(source_files_dir)
    subprocess.run([
        "xorriso", "-as", "mkisofs", "-r",
        "-V", "Ubuntu 22.04 LTS AUTO (EFIBIOS)",
        "-o", iso_output_path,
        "--grub2-mbr", os.path.join(boot_dir, "1-Boot-NoEmul.img"),
        "-partition_offset", "16",
        "--mbr-force-bootable",
        "-append_partition", "2", "28732ac11ff8d211ba4b00a0c93ec93b", os.path.join(boot_dir, "2-Boot-NoEmul.img"),
        "-appended_part_as_gpt",
        "-iso_mbr_part_type", "a2a0d0ebe5b9334487c068b6b72699c7",
        "-c", "/boot.catalog",
        "-b", "/boot/grub/i386-pc/eltorito.img",
        "-no-emul-boot", "-boot-load-size", "4", "-boot-info-table",
        "--grub2-boot-info",
        "-eltorito-alt-boot",
        "-e", "--interval:appended_partition_2:::",
        "-no-emul-boot", "."
    ], check=True)
    print(f"{COLOR_GREEN}ISO creada en '{iso_output_path}'.{COLOR_RESET}")
