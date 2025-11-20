#!/bin/bash

set -e

# Read secrets from files
SQL_PASSWORD=$(cat /run/secrets/db_password)
SQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

# Ensure runtime dir exists
mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

# Initialize MariaDB on first run and bootstrap users/passwords
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB data directory..."
    if command -v mariadb-install-db >/dev/null 2>&1; then
        mariadb-install-db --user=mysql --datadir=/var/lib/mysql
    else
        mysql_install_db --user=mysql --datadir=/var/lib/mysql
    fi

    echo "Bootstrapping initial database users and permissions..."
    cat > /tmp/init.sql <<EOF
-- Secure root and create database and user
ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;
CREATE USER IF NOT EXISTS \`${SQL_USER}\`@'%' IDENTIFIED BY '${SQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO \`${SQL_USER}\`@'%';
FLUSH PRIVILEGES;
EOF

    # Run bootstrap (executes SQL as system root without needing a password)
    mysqld --user=mysql --datadir=/var/lib/mysql --bootstrap < /tmp/init.sql
    rm -f /tmp/init.sql
    echo "Bootstrap complete."
fi

echo "Starting MariaDB in safe mode..."
exec mysqld_safe --user=mysql


