FROM php:7.4-fpm-buster

ENV COMPOSER_ALLOW_SUPERUSER=1

RUN  sed -i 's/deb.debian.org/opensource.nchc.org.tw/g'  /etc/apt/sources.list

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libmemcached-dev \
        libz-dev \
        libpq-dev \
        libssl-dev \
        libmcrypt-dev \
        openssh-server \
        libmagickwand-dev \
        git \
        cron \
        nano \
        libxml2-dev \
        libzip-dev \
        unzip \
        && rm -r /var/lib/apt/lists/*

# Install the PHP extention
RUN docker-php-ext-install pcntl zip pdo_mysql bcmath intl

# Install composer and add its bin to the PATH.
RUN curl -s http://getcomposer.org/installer | php && \
    echo "export PATH=${PATH}:/var/www/vendor/bin" >> ~/.bashrc && \
    mv composer.phar /usr/local/bin/composer
# Source the bash
RUN . ~/.bashrc

#install parallel composer install
RUN composer global require hirak/prestissimo

# Nginx
RUN apt-get update && \
    apt-get install -y nginx  && \
    rm -rf /var/lib/apt/lists/*

COPY . /var/www/html

WORKDIR /var/www/html

RUN composer install

RUN rm /etc/nginx/sites-enabled/default

COPY ./deploy/deploy.conf /etc/nginx/conf.d/default.conf

RUN mv /usr/local/etc/php-fpm.d/www.conf /usr/local/etc/php-fpm.d/www.conf.backup

COPY ./deploy/www.conf /usr/local/etc/php-fpm.d/www.conf

RUN usermod -a -G www-data root
RUN chgrp -R www-data storage

RUN chown -R www-data:www-data ./storage
RUN chmod -R 0777 ./storage

RUN rm .env && ln -s ./secret/.env .env

RUN chmod +x ./deploy/run

ENTRYPOINT ["sh", "./deploy/run"]

EXPOSE 80
