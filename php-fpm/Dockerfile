FROM php:7.4-fpm

WORKDIR /var/www

RUN apt-get update && apt-get install -y libmcrypt-dev zip unzip git \
    libmagickwand-dev --no-install-recommends \
    && pecl install imagick \
    && docker-php-ext-enable imagick \
    && docker-php-ext-install pdo_mysql pcntl bcmath \
    && docker-php-ext-install opcache

COPY ./laravel.ini /usr/local/etc/php/conf.d
COPY ./opcache.ini /usr/local/etc/php/conf.d
COPY ./xlaravel.pool.conf /usr/local/etc/php-fpm.d/
