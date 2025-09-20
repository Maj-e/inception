FROM debian:bookworm

# Install PHP and necessary extensions
RUN apt-get update && \
    apt-get install -y \
        php8.2 \
        php8.2-fpm \
        php8.2-mysql \
        php8.2-mbstring \
        wget \
        nginx && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Download Adminer
RUN wget https://www.adminer.org/latest.php -O /var/www/html/index.php && \
    chown -R www-data:www-data /var/www/html && \
    chmod 755 /var/www/html

# Configure Nginx
COPY conf/nginx.conf /etc/nginx/sites-available/default
COPY conf/adminer.conf /etc/php/8.2/fpm/pool.d/www.conf

# Create run directory for PHP-FPM
RUN mkdir -p /run/php

EXPOSE 8080

# Start script
COPY tools/start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]