FROM debian:bookworm

# 1) Installer PHP-FPM + extensions nécessaires + outils
RUN apt-get update && \
    apt-get install -y \
        php-fpm \
        php-mysql \
        php-cli \
        php-curl \
        php-xml \
        php-mbstring \
        php-zip \
        php-gd \
        wget \
        curl \
        mariadb-client && \
    rm -rf /var/lib/apt/lists/*

# 2) Dossier de travail
WORKDIR /var/www/wordpress

# 3) (Optionnel) créer le dossier, mais le contenu viendra surtout du volume + entrypoint
RUN mkdir -p /var/www/wordpress

# 4) Config PHP-FPM : écouter sur 0.0.0.0:9000 au lieu du socket
RUN sed -i 's|^listen = .*|listen = 0.0.0.0:9000|' /etc/php/*/fpm/pool.d/www.conf

# 5) Script d'entrée
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 9000

ENTRYPOINT ["entrypoint.sh"]
