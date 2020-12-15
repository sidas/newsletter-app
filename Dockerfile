FROM php:7.4-fpm

# Set working directory
WORKDIR /var/www

RUN runtimeDeps=" \
        curl \
        git \
        zip \
        libc-client-dev \
        libkrb5-dev \
        libxml2-dev \
        libonig-dev \
        libmemcached-dev \
    " \
    && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y $runtimeDeps \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install iconv mbstring imap \
    && rm -r /var/lib/apt/lists/*

RUN apt-get update -y && apt-get install -y sendmail libpng-dev

RUN apt-get update && apt-get install -y \
    zlib1g-dev \
    libzip-dev \
    libfreetype6-dev \
    libpng-dev \
    libjpeg-dev

RUN pecl install -o -f redis \
    &&  rm -rf /tmp/pear \
    &&  docker-php-ext-enable redis

RUN pecl install memcached \
    && docker-php-ext-enable memcached

# Install PHP extensions
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN curl -sL https://deb.nodesource.com/setup_12.x -o nodesource_setup.sh && bash nodesource_setup.sh && apt-get -y --force-yes install nodejs

RUN pecl install -f xdebug \
   && docker-php-ext-enable xdebug

# Change current user to www
USER root

# Expose port 9000 and start php-fpm server
EXPOSE 9001
CMD ["php-fpm"]

ADD . /var/www/html
RUN chown -R www-data:www-data /var/www/html