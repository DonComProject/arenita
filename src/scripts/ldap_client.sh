# Actualizar la maquina
sudo apt update
sudo apt install libpam-ldapd libnss-ldapd ldap-utils
echo "client" > /etc/hostname
wget https://raw.githubusercontent.com/DonComProject/arenita/main/src/conf/common-auth > /etc/pam.d/common-auth
sudo systemctl restart nslcd
wget https://raw.githubusercontent.com/DonComProject/arenita/main/src/conf/nsswitch.conf > /etc/nsswitch.conf
