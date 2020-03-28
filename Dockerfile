FROM php:7.4.4-apache-buster
ARG GETSIMPLE_VERSION=3.3.15
WORKDIR /var/www/html
RUN apt-get update && \
    apt-get -y install curl zip libzip-dev libgd-dev && \
    apt-get clean
RUN curl -LO http://get-simple.info/data/uploads/releases/GetSimpleCMS-$GETSIMPLE_VERSION.zip && \
    unzip GetSimpleCMS-$GETSIMPLE_VERSION.zip && \
    mv GetSimpleCMS-$GETSIMPLE_VERSION/* . && \
    rm -rf GetSimpleCMS-$GETSIMPLE_VERSION.zip GetSimpleCMS-$GETSIMPLE_VERSION/
RUN mv $PHP_INI_DIR/php.ini-development $PHP_INI_DIR/php.ini
RUN docker-php-ext-configure gd \
        --with-freetype-dir=/usr/lib/ \
        --with-png-dir=/usr/lib/ \
        --with-jpeg-dir=/usr/lib/ \
        --with-gd
RUN docker-php-ext-install -j$(nproc) gd
RUN docker-php-ext-configure zip && \
    docker-php-ext-install -j$(nproc) zip
RUN docker-php-ext-install -j$(nproc) opcache
RUN a2enmod rewrite
RUN chown -R www-data.www-data .
EXPOSE 80
