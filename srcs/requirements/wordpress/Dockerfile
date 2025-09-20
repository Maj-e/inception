FROM debian:bookworm

RUN apt-get update -y
RUN apt-get upgrade -y

# Installer wget pour télécharger WordPress
RUN apt-get install -y wget

# Installer PHP 8.2 et ses dépendances (disponible sur bookworm)
RUN apt-get install -y \
    php8.2 \
    php8.2-fpm \
    php8.2-mysql \
    php8.2-curl \
    php8.2-gd \
    php8.2-xml \
    php8.2-mbstring \
    php8.2-zip \
    mariadb-client

# Télécharger WordPress en anglais (version stable)
RUN wget https://wordpress.org/latest.tar.gz -P /var/www

# Décompresser WordPress et nettoyer
RUN cd /var/www && tar -xzf latest.tar.gz && rm latest.tar.gz

# Donner les droits à root
RUN chown -R root:root /var/www/wordpress

# Installer WP-CLI
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN chmod +x wp-cli.phar
RUN mv wp-cli.phar /usr/local/bin/wp

# Copier les fichiers de configuration
COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY conf/auto_config.sh /auto_config.sh
RUN chmod +x /auto_config.sh

WORKDIR /var/www/wordpress

EXPOSE 9000

ENTRYPOINT ["/auto_config.sh"]