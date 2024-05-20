# Actualizar la maquina
sudo apt update
sudo apt install libpam-ldapd libnss-ldapd ldap-utils
echo "client" > /etc/hostname
sudo wget https://raw.githubusercontent.com/DonComProject/arenita/main/src/conf/common-auth > /etc/pam.d/common-auth
sudo wget https://raw.githubusercontent.com/DonComProject/arenita/main/src/conf/common-account > /etc/pam.d/common-account
sudo wget https://raw.githubusercontent.com/DonComProject/arenita/main/src/conf/common-password > /etc/pam.d/common-password
sudo wget https://raw.githubusercontent.com/DonComProject/arenita/main/src/conf/common-session > /etc/pam.d/common-session
sudo systemctl restart nslcd
sudo wget https://raw.githubusercontent.com/DonComProject/arenita/main/src/conf/nsswitch.conf > /etc/nsswitch.conf
