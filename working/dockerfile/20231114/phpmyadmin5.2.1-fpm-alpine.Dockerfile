# DO NOT EDIT: created by update.sh from Dockerfile-alpine.template
FROM php:8.2-fpm-alpine

# docker-entrypoint.sh dependencies
RUN apk add --no-cache \
    bash \
    tzdata

# Install dependencies
RUN set -ex; \
    \
    apk add --no-cache --virtual .build-deps \
        bzip2-dev \
        freetype-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        libwebp-dev \
        libxpm-dev \
        libzip-dev \
    ; \
    \
    docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp --with-xpm; \
    docker-php-ext-install -j "$(nproc)" \
        bz2 \
        gd \
        mysqli \
        opcache \
        zip \
        bcmath \
    ; \
    \
    runDeps="$( \
        scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/lib/php/extensions \
            | tr ',' '\n' \
            | sort -u \
            | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )"; \
    apk add --no-network --virtual .phpmyadmin-phpexts-rundeps $runDeps; \
    apk del --no-network .build-deps

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
ENV MAX_EXECUTION_TIME 600
ENV MEMORY_LIMIT 512M
ENV UPLOAD_LIMIT 2048K
ENV TZ UTC
ENV SESSION_SAVE_PATH /sessions
RUN set -ex; \
    \
    { \
        echo 'opcache.memory_consumption=128'; \
        echo 'opcache.interned_strings_buffer=8'; \
        echo 'opcache.max_accelerated_files=4000'; \
        echo 'opcache.revalidate_freq=2'; \
        echo 'opcache.fast_shutdown=1'; \
    } > $PHP_INI_DIR/conf.d/opcache-recommended.ini; \
    \
    { \
        echo 'session.cookie_httponly=1'; \
        echo 'session.use_strict_mode=1'; \
    } > $PHP_INI_DIR/conf.d/session-strict.ini; \
    \
    { \
        echo 'allow_url_fopen=Off'; \
        echo 'max_execution_time=${MAX_EXECUTION_TIME}'; \
        echo 'max_input_vars=10000'; \
        echo 'memory_limit=${MEMORY_LIMIT}'; \
        echo 'post_max_size=${UPLOAD_LIMIT}'; \
        echo 'upload_max_filesize=${UPLOAD_LIMIT}'; \
        echo 'date.timezone=${TZ}'; \
        echo 'session.save_path=${SESSION_SAVE_PATH}'; \
    } > $PHP_INI_DIR/conf.d/phpmyadmin-misc.ini

# Calculate download URL
ENV VERSION 5.2.1
ENV SHA256 373f9599dfbd96d6fe75316d5dad189e68c305f297edf42377db9dd6b41b2557
ENV URL https://files.phpmyadmin.net/phpMyAdmin/${VERSION}/phpMyAdmin-${VERSION}-all-languages.tar.xz

LABEL org.opencontainers.image.title="Official phpMyAdmin Docker image" \
    org.opencontainers.image.description="Run phpMyAdmin with Alpine, Apache and PHP FPM." \
    org.opencontainers.image.authors="The phpMyAdmin Team <developers@phpmyadmin.net>" \
    org.opencontainers.image.vendor="phpMyAdmin" \
    org.opencontainers.image.documentation="https://github.com/phpmyadmin/docker#readme" \
    org.opencontainers.image.licenses="GPL-2.0-only" \
    org.opencontainers.image.version="${VERSION}" \
    org.opencontainers.image.url="https://github.com/phpmyadmin/docker#readme" \
    org.opencontainers.image.source="https://github.com/phpmyadmin/docker.git"

# Download tarball, verify it using gpg and extract
RUN set -ex; \
    apk add --no-cache --virtual .fetch-deps \
        gnupg \
    ; \
    mkdir $SESSION_SAVE_PATH; \
    chmod 1777 $SESSION_SAVE_PATH; \
    chown www-data:www-data $SESSION_SAVE_PATH; \
    \
    export GNUPGHOME="$(mktemp -d)"; \
    export GPGKEY="3D06A59ECE730EB71B511C17CE752F178259BD92"; \
    curl -fsSL -o phpMyAdmin.tar.xz $URL; \
    curl -fsSL -o phpMyAdmin.tar.xz.asc $URL.asc; \
    echo "$SHA256 *phpMyAdmin.tar.xz" | sha256sum -c -; \
    gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$GPGKEY" \
        || gpg --batch --keyserver pgp.mit.edu --recv-keys "$GPGKEY" \
        || gpg --batch --keyserver keyserver.pgp.com --recv-keys "$GPGKEY" \
        || gpg --batch --keyserver keys.openpgp.org --recv-keys "$GPGKEY"; \
    gpg --batch --verify phpMyAdmin.tar.xz.asc phpMyAdmin.tar.xz; \
    tar -xf phpMyAdmin.tar.xz -C /var/www/html --strip-components=1; \
    mkdir -p /var/www/html/tmp; \
    chown www-data:www-data /var/www/html/tmp; \
    gpgconf --kill all; \
    rm -r "$GNUPGHOME" phpMyAdmin.tar.xz phpMyAdmin.tar.xz.asc; \
    rm -r -v /var/www/html/setup/ /var/www/html/examples/ /var/www/html/js/src/ /var/www/html/babel.config.json /var/www/html/doc/html/_sources/ /var/www/html/RELEASE-DATE-$VERSION /var/www/html/CONTRIBUTING.md; \
    grep -q -F "'configFile' => ROOT_PATH . 'config.inc.php'," /var/www/html/libraries/vendor_config.php; \
    sed -i "s@'configFile' => .*@'configFile' => '/etc/phpmyadmin/config.inc.php',@" /var/www/html/libraries/vendor_config.php; \
    grep -q -F "'configFile' => '/etc/phpmyadmin/config.inc.php'," /var/www/html/libraries/vendor_config.php; \
    php -l /var/www/html/libraries/vendor_config.php; \
    apk del --no-network .fetch-deps

# Copy configuration
COPY config.inc.php /etc/phpmyadmin/config.inc.php

# Copy main script
COPY docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD ["php-fpm"]
