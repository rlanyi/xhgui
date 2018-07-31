FROM php:5-fpm

LABEL maintainer="Robert Lanyi <lanyi.robert.attila@gmail.com>"
LABEL original_maintainer="Vitaly Bolychev <vitaly.bolychev@gmail.com>"

# install necessary packages
RUN apt-get update && apt-get install -y gnupg2 libzip-dev libssl-dev libmcrypt-dev && apt-get clean && rm -rf /var/lib/apt/lists/*

# create data directories
RUN mkdir -p /data/import && chmod -R 777 /data

# set php timezone
RUN echo "date.timezone = 'Europe/Moscow'" > /usr/local/etc/php/conf.d/timezone.ini

# install mongodb driver and zip extension via pecl
RUN pecl install mongodb && docker-php-ext-enable mongodb && pecl install zip && docker-php-ext-enable zip

ADD ./ /var/www/xhgui/

WORKDIR /var/www/xhgui

# composer install
RUN php install.php && chown -R www-data:www-data /var/www/xhgui

# start php internal webserver
CMD find /data/import -type f -name '*.json' -exec echo Importing {} \; -exec php /var/www/xhgui/external/import.php -f {} \; && echo Starting webserver... && php -S 0.0.0.0:80 -t webroot

EXPOSE 80
