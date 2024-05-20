from imports import *
from constants import *

def get_next_uid():
    current_dir = os.path.dirname(os.path.abspath(__file__))
    uid_counter_file = os.path.join(current_dir, "uid_counter.txt")
    if not os.path.exists(uid_counter_file):
        with open(uid_counter_file, 'w') as f:
            f.write('10001')
    with open(uid_counter_file, 'r+') as f:
        uid = int(f.read().strip())
        next_uid = uid + 1
        f.seek(0)
        f.write(str(next_uid))
        f.truncate()
    return uid

def create_ldif_entry(uid, sn, given_name, cn, display_name, uid_number, gid_number, user_password, login_shell, home_directory):
    ldif_entry = f"""dn: uid={uid},ou=users,dc=doncom,dc=com
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
uid: {uid}
sn: {sn}
givenName: {given_name}
cn: {cn}
displayName: {display_name}
uidNumber: {uid_number}
gidNumber: {gid_number}
userPassword: {user_password}
loginShell: {login_shell}
homeDirectory: {home_directory}
"""
    return ldif_entry

def save_ldif_file(entry, uid):
    filename = f"{uid}.ldif"
    with open(filename, 'w') as f:
        f.write(entry)

def generate_username(given_name, sn):
    first_letter = given_name[0].lower()
    shortened_sn = sn[:5].lower()
    random.seed(time.time())
    random_number = random.randint(10, 99)
    username = f"{first_letter}{shortened_sn}{random_number}"
    return username
