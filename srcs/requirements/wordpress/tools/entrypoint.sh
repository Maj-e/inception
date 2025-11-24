#!/bin/bash
set -e

WP_PATH="/var/www/wordpress"
CONFIG_FILE="${WP_PATH}/wp-config.php"

echo ">>> WordPress entrypoint..."

# 1) Si le volume est vide, on télécharge WordPress
if [ -z "$(ls -A "${WP_PATH}")" ]; then
    echo ">>> Copying WordPress core files into volume..."
    tmp_dir="/tmp/wp"
    mkdir -p "${tmp_dir}"
    wget -q https://wordpress.org/latest.tar.gz -O /tmp/wordpress.tar.gz
    tar -xzf /tmp/wordpress.tar.gz -C "${tmp_dir}"
    cp -R "${tmp_dir}/wordpress/"* "${WP_PATH}/"
    rm -rf "${tmp_dir}" /tmp/wordpress.tar.gz
fi

# 2) Génération du wp-config.php si absent
if [ ! -f "${CONFIG_FILE}" ]; then
    echo ">>> Generating wp-config.php..."
    cp "${WP_PATH}/wp-config-sample.php" "${CONFIG_FILE}"

    sed -i "s/database_name_here/${MYSQL_DATABASE}/" "${CONFIG_FILE}"
    sed -i "s/username_here/${MYSQL_USER}/" "${CONFIG_FILE}"
    sed -i "s/password_here/${MYSQL_PASSWORD}/" "${CONFIG_FILE}"
    sed -i "s/localhost/mariadb/" "${CONFIG_FILE}"
fi

echo ">>> Starting PHP-FPM..."
exec php-fpm8.2 -F
