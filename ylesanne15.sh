#!/bin/bash
set -e

sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install -y \
  apache2 mariadb-server php libapache2-mod-php php-mysql phpmyadmin openssl

sudo systemctl enable --now apache2
sudo systemctl enable --now mariadb

sudo sed -i '/^[[:space:]]*ServerTokens/d; /^[[:space:]]*ServerSignature/d' \
  /etc/apache2/conf-available/security.conf
echo "ServerTokens Prod" | sudo tee -a /etc/apache2/conf-available/security.conf > /dev/null
echo "ServerSignature Off" | sudo tee -a /etc/apache2/conf-available/security.conf > /dev/null

sudo tee /etc/apache2/conf-available/no-indexes.conf > /dev/null <<'EOF'
<Directory /var/www/>
    Options -Indexes
</Directory>
EOF

sudo a2enconf security
sudo a2enconf no-indexes
sudo a2enmod ssl

sudo install -d -m 755 /etc/ssl/certs
sudo install -d -m 700 /etc/ssl/private

sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/apache-selfsigned.key \
  -out /etc/ssl/certs/apache-selfsigned.crt \
  -subj "/CN=localhost"

sudo tee /etc/apache2/sites-available/default-ssl.conf > /dev/null <<'EOF'
<IfModule mod_ssl.c>
<VirtualHost _default_:443>
    DocumentRoot /var/www/html
    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/apache-selfsigned.crt
    SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key
</VirtualHost>
</IfModule>
EOF

sudo find /etc/apache2 -type f -name '*.conf' \
  -exec sed -i \
  -e 's|^[[:space:]]*SSLCertificateFile .*|    SSLCertificateFile /etc/ssl/certs/apache-selfsigned.crt|' \
  -e 's|^[[:space:]]*SSLCertificateKeyFile .*|    SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key|' \
  {} \;
  
sudo a2ensite default-ssl

sudo apache2ctl configtest
sudo systemctl restart apache2

if [ -f /etc/ssl/certs/apache-selfsigned.crt ] && [ -f /etc/ssl/private/apache-selfsigned.key ]; then
  echo "[KORRAS] Sertifikaadi failid on olemas"
else
  echo "[PUUDU] Sertifikaadi failid puuduvad"
  exit 1
fi

echo "Seadistamine on lõpetatud."
