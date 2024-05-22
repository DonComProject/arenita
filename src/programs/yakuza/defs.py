# defs.py

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
