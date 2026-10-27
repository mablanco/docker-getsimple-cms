FROM php:8.4.27-apache@sha256:c6527b06c772a2c3cae648ce58c23a2a12ed2fed41cdfb0619ea64be008cc601
ARG DEBIAN_FRONTEND=noninteractive
ARG GETSIMPLE_VERSION=3.3.22
ARG GETSIMPLE_SHA256=430b09b8eb86c840567e34780ff44e6a0af85b34a052ec858c85b168f7c162f3
WORKDIR /var/www/html
# Build the PHP extensions, then keep only the runtime libraries they link to
RUN set -eux; \
    savedAptMark="$(apt-mark showmanual)"; \
    apt-get update; \
    apt-get -y upgrade; \
    apt-get -y install --no-install-recommends \
        libfreetype-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libwebp-dev \
        libzip-dev; \
    docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp; \
    docker-php-ext-install -j"$(nproc)" gd opcache zip; \
    apt-mark auto '.*' > /dev/null; \
    apt-mark manual $savedAptMark; \
    ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
        | awk '/=>/ { so = $(NF-1); if (index(so, "/usr/local/") == 1) { next }; gsub("^/(usr/)?", "", so); printf "*%s\n", so }' \
        | sort -u \
        | xargs -r dpkg-query --search \
        | cut -d: -f1 \
        | sort -u \
        | xargs -r apt-mark manual; \
    apt-get -y purge --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    rm -rf /var/lib/apt/lists/*
# GetSimple CMS Community Edition, the maintained fork of GetSimple CMS
RUN set -eux; \
    curl -fsSL -o getsimple.tar.gz \
        "https://github.com/GetSimpleCMS-CE/GetSimpleCMS-CE/archive/refs/tags/v${GETSIMPLE_VERSION}.tar.gz"; \
    echo "${GETSIMPLE_SHA256}  getsimple.tar.gz" | sha256sum -c -; \
    tar xzf getsimple.tar.gz --strip-components=1; \
    rm getsimple.tar.gz; \
    mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"; \
    a2enmod rewrite; \
    chown -R www-data:www-data .
EXPOSE 80
