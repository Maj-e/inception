#!/bin/bash
set -e

DATADIR="/var/lib/mysql"

if [ ! -d "${DATADIR}/mysql" ]; then
    echo ">>> Initialisation of MariaDB..."
    mariadb-install-db --user=mysql --datadir="${DATADIR}" > /dev/null

    echo ">>> Users database initialisation..."
    mysqld --user=mysql --datadir="${DATADIR}" --bootstrap << EOF
FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF
fi

echo ">>>MariaDB starting ..."
exec mysqld --user=mysql --datadir="${DATADIR}" --console
chmod +x tools/entrypoint.sh