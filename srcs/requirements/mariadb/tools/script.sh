#!/bin/bash

# Read secrets from files
SQL_PASSWORD=$(cat /run/secrets/db_password)
SQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

# Initialize MariaDB if not already done
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB database..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

# Create directory for socket
mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

# Start MariaDB (not mysql!)
service mariadb start

# Wait for MariaDB to be ready
echo "Waiting for MariaDB to be ready..."
sleep 10

# Check if MariaDB is started
while ! mysqladmin ping >/dev/null 2>&1; do
    echo "Waiting for MariaDB..."
    sleep 1
done

echo "MariaDB is ready! Creating database and user..."

# Create database and user
mysql -e "CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;"
mysql -e "CREATE USER IF NOT EXISTS \`${SQL_USER}\`@'%' IDENTIFIED BY '${SQL_PASSWORD}';"
mysql -e "GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO \`${SQL_USER}\`@'%';"
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';"
mysql -e "CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';"
mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%';"
mysql -e "FLUSH PRIVILEGES;"

echo "Database setup complete! Restarting MariaDB in safe mode..."

# Stop MariaDB properly
mysqladmin -u root -p${SQL_ROOT_PASSWORD} shutdown

# Restart in daemon mode
exec mysqld_safe --user=mysql


