#!/bin/bash
set -euo pipefail

BACKUP_DIR="/var/backups"
DATE=$(date +"%Y%m%d")

mkdir -p "$BACKUP_DIR"

# Apache, PHP ja SSL seadistused
tar -czf "$BACKUP_DIR/seaded_$DATE.tar.gz" /etc/apache2 /etc/php /etc/ssl

# Veebilehe failid
tar -czf "$BACKUP_DIR/veeb_$DATE.tar.gz" /var/www/html

# MariaDB andmebaasid
mariadb-dump --all-databases | gzip > "$BACKUP_DIR/andmebaasid_$DATE.sql.gz"

# Varukoopiad ainult administraatorile loetavaks
chmod 600 "$BACKUP_DIR"/*_"$DATE".*

# Kustuta üle 7 päeva vanad varukoopiad
find "$BACKUP_DIR" -type f -mtime +7 -delete

echo "Varukoopia valmis: $BACKUP_DIR"
