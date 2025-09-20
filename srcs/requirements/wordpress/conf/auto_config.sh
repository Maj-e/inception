#!/bin/bash

# Read secrets from files
SQL_PASSWORD=$(cat /run/secrets/db_password)
CREDENTIALS=$(cat /run/secrets/credentials)
ADMIN_USER=$(echo "$CREDENTIALS" | head -1 | cut -d: -f1)
ADMIN_PASS=$(echo "$CREDENTIALS" | head -1 | cut -d: -f2)
USER2_USER=$(echo "$CREDENTIALS" | tail -1 | cut -d: -f1)
USER2_PASS=$(echo "$CREDENTIALS" | tail -1 | cut -d: -f2)

# Create /run/php directory if it doesn't exist (avoid PHP errors)
if [ ! -d "/run/php" ]; then
    mkdir -p /run/php
fi

# Wait for MariaDB to be ready (precaution)
sleep 10

# Check if MariaDB is accessible
while ! mariadb -h"mariadb" -u"${SQL_USER}" -p"${SQL_PASSWORD}" -e "SELECT 1" >/dev/null 2>&1; do
    echo "Waiting for MariaDB to be ready..."
    sleep 2
done

echo "MariaDB is ready! Configuring WordPress..."

# Configure WordPress only if wp-config.php doesn't exist
if [ ! -f "/var/www/wordpress/wp-config.php" ]; then
    echo "Creating WordPress configuration..."
    
    # Create database configuration
    wp config create --allow-root \
        --dbname="${SQL_DATABASE}" \
        --dbuser="${SQL_USER}" \
        --dbpass="${SQL_PASSWORD}" \
        --dbhost="mariadb:3306" \
        --path="/var/www/wordpress"
    
    echo "Installing WordPress core..."
    
    # Install WordPress with first admin user (using wpowner instead of admin)
    wp core install --allow-root \
        --url="https://${DOMAIN_NAME}" \
        --title="Inception WordPress Site" \
        --admin_user="${ADMIN_USER}" \
        --admin_password="${ADMIN_PASS}" \
        --admin_email="${ADMIN_USER}@${DOMAIN_NAME}" \
        --path="/var/www/wordpress"
    
    echo "Creating second WordPress user..."
    
    # Create second WordPress user
    wp user create "${USER2_USER}" "${USER2_USER}@${DOMAIN_NAME}" \
        --role="author" \
        --user_pass="${USER2_PASS}" \
        --allow-root \
        --path="/var/www/wordpress"
    
    echo "WordPress configuration complete!"
else
    echo "WordPress already configured, skipping setup..."
fi

echo "Starting PHP-FPM..."

# Start PHP-FPM in foreground mode
exec /usr/sbin/php-fpm8.2 -F