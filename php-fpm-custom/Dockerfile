FROM php:7.4-fpm

WORKDIR /var/www

RUN apt-get update && apt-get install -y libmcrypt-dev zip unzip git \
    libmagickwand-dev --no-install-recommends \
    && pecl install imagick \
    && docker-php-ext-enable imagick \
    && docker-php-ext-install pdo_mysql pcntl bcmath

COPY . /var/www

RUN chown -R www-data:www-data \
        /var/www/storage \
        /var/www/bootstrap/cache

RUN mkdir -p /tmp/storage/bootstrap/cache \
    && chmod 777 -R /tmp/storage/bootstrap/cache
