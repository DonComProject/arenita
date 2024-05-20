from imports import *
from constants import *
from defs import *

def ask_user_info():
    given_name = input("Nombre: ")
    sn = input("Apellido: ")
    user_password = input("Contraseña: ")

    while True:
        login_shell_input = input("¿Puede tener terminal? (yes/no): ").strip().lower()
        if login_shell_input == "yes":
            login_shell = "/bin/bash"
            break
        elif login_shell_input == "no":
            login_shell = "/bin/false"
            break
        else:
            print("Entrada inválida. Por favor, escriba 'yes' o 'no'.")

    uid = generate_username(given_name, sn)
    uid_number = get_next_uid()
    cn = f"{given_name} {sn}"
    display_name = cn
    home_directory = f"/home/{uid}"

    ldif_entry = create_ldif_entry(uid, sn, given_name, cn, display_name, uid_number, GID_NUMBER, user_password, login_shell, home_directory)
    save_ldif_file(ldif_entry, uid)

    return uid

def main():
    while True:
        uid = ask_user_info()
        print(f"{COLOR_GREEN}Archivo LDIF generado correctamente: {uid}.ldif{COLOR_RESET}")
        more_users = input("¿Desea agregar otro usuario? (yes/no): ").strip().lower()
        if more_users != "yes":
            break

if __name__ == "__main__":
    main()
