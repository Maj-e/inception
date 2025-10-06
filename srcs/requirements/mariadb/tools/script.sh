#!/bin/bash

# Read secrets from files
SQL_PASSWORD=$(cat /run/secrets/db_password)
SQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

# Create directory for socket
mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

# Check if our custom database configuration is done
if [ ! -f "/var/lib/mysql/.inception_configured" ]; then
    echo "First time setup - configuring database..."
    echo "Variables: DB=${SQL_DATABASE}, USER=${SQL_USER}"
    
    # Remove existing data to start fresh
    rm -rf /var/lib/mysql/*
    
    # Initialize MariaDB
    echo "Initializing MariaDB database..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
    
    # Start MariaDB in background for setup
    mysqld_safe --user=mysql --skip-grant-tables &
    MARIADB_PID=$!
    
    # Wait for MariaDB to be ready
    echo "Waiting for MariaDB to be ready..."
    sleep 10
    
    while ! mysqladmin ping >/dev/null 2>&1; do
        echo "Still waiting for MariaDB..."
        sleep 3
    done
    
    echo "MariaDB ready! Configuring database..."
    
    # Configure database and user without password (skip-grant-tables mode)
    mysql << EOSQL
USE mysql;
FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${SQL_USER}'@'%' IDENTIFIED BY '${SQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO '${SQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOSQL
    
    if [ $? -eq 0 ]; then
        echo "Configuration complete! Databases and users created."
        
        # Verify user was created
        echo "Verifying user creation..."
        USER_EXISTS=$(mysql -e "SELECT User FROM mysql.user WHERE User='${SQL_USER}';" -sN 2>/dev/null)
        if [ ! -z "$USER_EXISTS" ]; then
            echo "✓ User ${SQL_USER} successfully created"
            # Mark as configured
            touch /var/lib/mysql/.inception_configured
            echo "Database marked as configured."
        else
            echo "✗ ERROR: User ${SQL_USER} was not created!"
            exit 1
        fi
    else
        echo "ERROR: Database configuration failed!"
        exit 1
    fi
    
    # Stop the temporary instance
    echo "Stopping temporary MariaDB instance..."
    kill $MARIADB_PID
    wait $MARIADB_PID 2>/dev/null
    
    echo "Database setup complete!"
else
    echo "Database already configured, skipping setup..."
fi

echo "Starting MariaDB in normal mode..."

# Start MariaDB normally
exec mysqld_safe --user=mysql
