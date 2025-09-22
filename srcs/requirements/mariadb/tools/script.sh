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

# Check if database is already configured
if [ ! -f "/var/lib/mysql/.db_configured" ]; then
    echo "First time setup - configuring database..."
    
    # Start MariaDB temporarily for setup
    mysqld_safe --user=mysql --skip-grant-tables --skip-networking &
    MARIADB_PID=$!
    
    # Wait for MariaDB to be ready
    echo "Waiting for MariaDB to be ready..."
    sleep 10
    
    while ! mysqladmin ping >/dev/null 2>&1; do
        echo "Waiting for MariaDB..."
        sleep 1
    done
    
    echo "MariaDB is ready! Creating database and user..."
    
    # Configure database and users
    mysql << EOF
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;
CREATE USER IF NOT EXISTS \`${SQL_USER}\`@'%' IDENTIFIED BY '${SQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO \`${SQL_USER}\`@'%';
FLUSH PRIVILEGES;
EOF
    
    # Mark as configured
    touch /var/lib/mysql/.db_configured
    
    # Stop the temporary MariaDB instance
    kill $MARIADB_PID
    wait $MARIADB_PID 2>/dev/null
    
    echo "Database setup complete!"
else
    echo "Database already configured, skipping setup..."
fi

echo "Starting MariaDB in normal mode..."

# Start in daemon mode
exec mysqld_safe --user=mysql
