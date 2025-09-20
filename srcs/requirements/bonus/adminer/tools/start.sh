#!/bin/bash

# Start PHP-FPM
echo "Starting PHP-FPM..."
php-fpm8.2 -D

# Start Nginx in foreground
echo "Starting Nginx..."
exec nginx -g "daemon off;"