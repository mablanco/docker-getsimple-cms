FROM php:7.4.4-apache-buster
ENV DEBIAN_FRONTEND noninteractive
ARG GETSIMPLE_VERSION=3.3.16
WORKDIR /var/www/html
RUN apt-get update && \
    apt-get -y install curl zip libzip-dev libgd-dev && \
    apt-get -yq autoremove && \
    apt-get clean && \
    rm -rf /var/lib/{apt,dpkg,cache,log}
RUN curl -s -LO http://get-simple.info/data/uploads/releases/GetSimpleCMS-$GETSIMPLE_VERSION.zip && \
    unzip GetSimpleCMS-$GETSIMPLE_VERSION.zip && \
    mv GetSimpleCMS-$GETSIMPLE_VERSION/* . && \
    rm -rf GetSimpleCMS-$GETSIMPLE_VERSION.zip GetSimpleCMS-$GETSIMPLE_VERSION/ && \
    mv $PHP_INI_DIR/php.ini-development $PHP_INI_DIR/php.ini && \
    docker-php-ext-configure gd \
        --with-freetype-dir=/usr/lib/ \
        --with-png-dir=/usr/lib/ \
        --with-jpeg-dir=/usr/lib/ \
        --with-gd && \
    docker-php-ext-configure zip && \
    docker-php-ext-install -j$(nproc) gd opcache zip && \
    a2enmod rewrite && \
    chown -R www-data.www-data .
EXPOSE 80
