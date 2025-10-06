FROM debian:bookworm

RUN apt-get update -y
RUN apt-get upgrade -y

RUN apt-get install -y wget

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

RUN wget https://wordpress.org/latest.tar.gz -P /var/www

RUN cd /var/www && tar -xzf latest.tar.gz && rm latest.tar.gz

RUN chown -R root:root /var/www/wordpress

RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN chmod +x wp-cli.phar
RUN mv wp-cli.phar /usr/local/bin/wp

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY conf/auto_config.sh /auto_config.sh
RUN chmod +x /auto_config.sh

WORKDIR /var/www/wordpress

EXPOSE 9000

ENTRYPOINT ["/auto_config.sh"]