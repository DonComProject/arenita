#!/bin/bash

# Abort on any error
set -e

# Variables
LDAP_DOMAIN="doncom"
LDAP_ORG="Doncom Organization"
LDAP_ADMIN_PASS="davidtomas"
LDAP_BASE_DN="dc=doncom"
LDAP_ADMIN_DN="cn=admin,dc=doncom"
DNS_SERVER_IP="127.0.0.1"
VEYON_CONFIG_DIR="/etc/veyon"
VEYON_JSON_FILE="$VEYON_CONFIG_DIR/veyon.json"
VEYON_CONFIG="$VEYON_CONFIG_DIR/veyon.conf"

# Verificar la variable VEYON_JSON_FILE
echo "VEYON_JSON_FILE: $VEYON_JSON_FILE"

# Get the IP address of the active network interface
IP_ADDRESS=$(ip route get 1 | awk '{print $NF;exit}')

# Get the network address and subnet mask
NETWORK=$(ipcalc -n $IP_ADDRESS | cut -d'=' -f2)
NETMASK=$(ipcalc -m $IP_ADDRESS | cut -d'=' -f2)

# Calculate the network range
NETWORK_RANGE="$NETWORK/$NETMASK"

# Update system
echo "Updating system..."
sudo apt-get update -y && sudo apt-get upgrade -y

# Install BIND DNS server
echo "Installing BIND DNS server..."
sudo apt-get install -y bind9 bind9utils bind9-doc

# Configure BIND
echo "Configuring BIND..."
sudo bash -c "cat > /etc/bind/named.conf.local <<EOF
zone \"$LDAP_DOMAIN\" {
    type master;
    file \"/etc/bind/db.$LDAP_DOMAIN\";
};
EOF"

sudo cp /etc/bind/db.local /etc/bind/db.$LDAP_DOMAIN
sudo bash -c "cat > /etc/bind/db.$LDAP_DOMAIN <<EOF
;
; BIND data file for $LDAP_DOMAIN
;
\$TTL    604800
@       IN      SOA     $LDAP_DOMAIN. admin.$LDAP_DOMAIN. (
                              1         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      $LDAP_DOMAIN.
@       IN      A       $DNS_SERVER_IP
$LDAP_DOMAIN.     IN      A       $DNS_SERVER_IP
EOF"

# Restart BIND service
sudo systemctl restart bind9
sudo systemctl enable named.service

# Install OpenLDAP and utilities
echo "Installing OpenLDAP and utilities..."
sudo apt-get install -y slapd ldap-utils

# Reconfigure OpenLDAP
echo "Reconfiguring OpenLDAP..."
sudo debconf-set-selections <<EOF
slapd slapd/internal/adminpw password $LDAP_ADMIN_PASS
slapd slapd/internal/generated_adminpw password $LDAP_ADMIN_PASS
slapd slapd/password1 password $LDAP_ADMIN_PASS
slapd slapd/password2 password $LDAP_ADMIN_PASS
slapd slapd/domain string $LDAP_DOMAIN
slapd shared/organization string "$LDAP_ORG"
slapd slapd/backend select MDB
slapd slapd/purge_database boolean true
slapd slapd/move_old_database boolean true
slapd slapd/allow_ldap_v2 boolean false
EOF

sudo dpkg-reconfigure -f noninteractive slapd

# Create LDAP base structure if it does not exist
BASE_DN_EXIST=$(ldapsearch -x -LLL -b "$LDAP_BASE_DN" 2>&1 | grep -c "dn: $LDAP_BASE_DN")
if [ "$BASE_DN_EXIST" -eq 0 ]; then
    echo "Creating LDAP base structure..."
    cat <<EOF | sudo ldapadd -Y EXTERNAL -H ldapi:///
dn: $LDAP_BASE_DN
objectClass: top
objectClass: dcObject
objectClass: organization
o: $LDAP_ORG
dc: doncom
EOF

    cat <<EOF | sudo ldapadd -x -D $LDAP_ADMIN_DN -w $LDAP_ADMIN_PASS
dn: $LDAP_BASE_DN
objectClass: top
objectClass: dcObject
objectClass: organization
o: $LDAP_ORG
dc: doncom

dn: $LDAP_ADMIN_DN
objectClass: simpleSecurityObject
objectClass: organizationalRole
cn: admin
userPassword: $(slappasswd -s $LDAP_ADMIN_PASS)
description: LDAP administrator

dn: ou=Users,$LDAP_BASE_DN
objectClass: organizationalUnit
ou: Users

dn: ou=Groups,$LDAP_BASE_DN
objectClass: organizationalUnit
ou: Groups

dn: ou=Computers,$LDAP_BASE_DN
objectClass: organizationalUnit
ou: Computers
EOF
fi

# Install Nmap
echo "Installing Nmap..."
sudo apt-get install -y nmap

# Perform network scan with Nmap to discover hosts
echo "Performing network scan with Nmap on $NETWORK_RANGE ..."
NMAP_OUTPUT=$(sudo nmap -sn $NETWORK_RANGE | grep "Nmap scan report" | cut -d' ' -f5)

# Create Veyon JSON configuration file
echo "Creating Veyon configuration file..."
sudo mkdir -p $VEYON_CONFIG_DIR

# Generate Veyon JSON configuration based on discovered hosts
echo "{" | sudo tee $VEYON_JSON_FILE > /dev/null
echo "    \"locations\": [" | sudo tee -a $VEYON_JSON_FILE > /dev/null

for HOST in $NMAP_OUTPUT; do
    echo "        {" | sudo tee -a $VEYON_JSON_FILE > /dev/null
    echo "            \"name\": \"$HOST\"," | sudo tee -a $VEYON_JSON_FILE > /dev/null
    echo "            \"computers\": [" | sudo tee -a $VEYON_JSON_FILE > /dev/null
    echo "                {" | sudo tee -a $VEYON_JSON_FILE > /dev/null
    echo "                    \"name\": \"$HOST\"," | sudo tee -a $VEYON_JSON_FILE > /dev/null
    echo "                    \"host\": \"$HOST\"" | sudo tee -a $VEYON_JSON_FILE > /dev/null
    echo "                }" | sudo tee -a $VEYON_JSON_FILE > /dev/null
    echo "            ]" | sudo tee -a $VEYON_JSON_FILE > /dev/null
    echo "        }," | sudo tee -a $VEYON_JSON_FILE > /dev/null
done

# Remove trailing comma from last entry
sudo sed -i '$s/,$//' $VEYON_JSON_FILE

echo "    ]" | sudo tee -a $VEYON_JSON_FILE > /dev/null
echo "}" | sudo tee -a $VEYON_JSON_FILE > /dev/null

echo "Veyon configuration file created successfully."

# Install Veyon
echo "Installing Veyon..."
sudo apt-get install -y libveyon-core veyon-configurator veyon-master veyon-plugins veyon-service

# Configure Veyon
echo "Configuring Veyon..."
sudo veyon-cli config set MasterKey "your_master_key_here"

# Restart Veyon service
sudo systemctl restart veyon.service
sudo systemctl enable veyon.service

echo "Veyon installed and configured successfully."

echo "    ]" | sudo /usr/bin/tee -a $VEYON_JSON_FILE > /dev/null
echo "}" | sudo /usr/bin/tee -a $VEYON_JSON_FILE > /dev/null
