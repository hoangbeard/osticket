FROM php:8.2.19-fpm-alpine3.19

LABEL maintainer="hoangbeard@outlook.com" \
    version="1.0.0" \
    description="Docker image for Nginx and PHP-FPM based on Alpine Linux."

# Install necessary alpine packages and PHP extensions
RUN apk update && apk add --no-cache \
    unzip \
    supervisor \
    freetype-dev \
    jpeg-dev \
    libpng-dev \
    libzip-dev \
    icu-dev \
    imap-dev \
    autoconf \
    gcc \
    g++ \
    make \
    gettext-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install opcache intl mysqli pdo pdo_mysql imap zip \
    && pecl install apcu \
    && docker-php-ext-enable apcu \
    && rm -rf /var/cache/apk/*

# Set environment variables
ENV NGINX_VERSION=1.26.0 \
    PKG_RELEASE=1 \
    NJS_VERSION=0.8.4 \
    NJS_RELEASE=2 \
    TZ=UTC

# Install nginx
RUN set -x \
    && apkArch="$(cat /etc/apk/arch)" \
    && nginxPackages=" \
    nginx=${NGINX_VERSION}-r${PKG_RELEASE} \
    nginx-module-xslt=${NGINX_VERSION}-r${PKG_RELEASE} \
    nginx-module-geoip=${NGINX_VERSION}-r${PKG_RELEASE} \
    nginx-module-image-filter=${NGINX_VERSION}-r${PKG_RELEASE} \
    nginx-module-njs=${NGINX_VERSION}.${NJS_VERSION}-r${NJS_RELEASE} \
    " \
    # install prerequisites for public key and pkg-oss checks
    && apk add --no-cache --virtual .checksum-deps \
    openssl \
    && case "$apkArch" in \
    x86_64|aarch64) \
    # arches officially built by upstream
    set -x \
    && KEY_SHA512="e09fa32f0a0eab2b879ccbbc4d0e4fb9751486eedda75e35fac65802cc9faa266425edf83e261137a2f4d16281ce2c1a5f4502930fe75154723da014214f0655" \
    && wget -O /tmp/nginx_signing.rsa.pub https://nginx.org/keys/nginx_signing.rsa.pub \
    && if echo "$KEY_SHA512 */tmp/nginx_signing.rsa.pub" | sha512sum -c -; then \
    echo "key verification succeeded!"; \
    mv /tmp/nginx_signing.rsa.pub /etc/apk/keys/; \
    else \
    echo "key verification failed!"; \
    exit 1; \
    fi \
    && apk add -X "https://nginx.org/packages/alpine/v$(egrep -o '^[0-9]+\.[0-9]+' /etc/alpine-release)/main" --no-cache $nginxPackages \
    ;; \
    *) \
    # we're on an architecture upstream doesn't officially build for
    # let's build binaries from the published packaging sources
    set -x \
    && tempDir="$(mktemp -d)" \
    && chown nobody:nobody $tempDir \
    && apk add --no-cache --virtual .build-deps \
    gcc \
    libc-dev \
    make \
    openssl-dev \
    pcre2-dev \
    zlib-dev \
    linux-headers \
    libxslt-dev \
    gd-dev \
    geoip-dev \
    libedit-dev \
    bash \
    alpine-sdk \
    findutils \
    && su nobody -s /bin/sh -c " \
    export HOME=${tempDir} \
    && cd ${tempDir} \
    && curl -f -O https://hg.nginx.org/pkg-oss/archive/73d6839714a2.tar.gz \
    && PKGOSSCHECKSUM=\"95d513d058493d60cba5a6bb328dc3c3e75ea115cf248a64bd921159e11c6fc87d33c7f058562c584fe440a219b931d53fd66bd4c596244b54287b62979834db *73d6839714a2.tar.gz\" \
    && if [ \"\$(openssl sha512 -r 73d6839714a2.tar.gz)\" = \"\$PKGOSSCHECKSUM\" ]; then \
    echo \"pkg-oss tarball checksum verification succeeded!\"; \
    else \
    echo \"pkg-oss tarball checksum verification failed!\"; \
    exit 1; \
    fi \
    && tar xzvf 73d6839714a2.tar.gz \
    && cd pkg-oss-73d6839714a2 \
    && cd alpine \
    && make module-geoip module-image-filter module-njs module-xslt \
    && apk index -o ${tempDir}/packages/alpine/${apkArch}/APKINDEX.tar.gz ${tempDir}/packages/alpine/${apkArch}/*.apk \
    && abuild-sign -k ${tempDir}/.abuild/abuild-key.rsa ${tempDir}/packages/alpine/${apkArch}/APKINDEX.tar.gz \
    " \
    && cp ${tempDir}/.abuild/abuild-key.rsa.pub /etc/apk/keys/ \
    && apk del --no-network .build-deps \
    && apk add -X ${tempDir}/packages/alpine/ --no-cache $nginxPackages \
    ;; \
    esac \
    # remove checksum deps
    && apk del --no-network .checksum-deps \
    # if we have leftovers from building, let's purge them (including extra, unnecessary build deps)
    && if [ -n "$tempDir" ]; then rm -rf "$tempDir"; fi \
    && if [ -f "/etc/apk/keys/abuild-key.rsa.pub" ]; then rm -f /etc/apk/keys/abuild-key.rsa.pub; fi \
    # Bring in curl and ca-certificates to make registering on DNS SD easier
    && apk add --no-cache curl ca-certificates

# Copy supervisor configuration
COPY ./supervisord/supervisord.conf /etc/supervisord.conf

# Use the default production configuration
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Copy custom PHP, PHP-FPM pool settings
# COPY ./php/conf.d/local.ini /usr/local/etc/php/conf.d/local.ini
COPY ./php/php-fpm.d/app-fpm.conf /usr/local/etc/php-fpm.d/app-fpm.conf

# Copy Nginx configuration files
COPY ./nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf

# Copy application files
COPY app/ /var/www/html/

# Set proper ownership for root directory and files
RUN chown -R www-data:www-data /var/www/html \
    && chmod 2775 /var/www/html && find /var/www/html -type d -exec chmod 2775 {} \; \
    && find /var/www/html -type f -exec chmod 0664 {} \;

# Ensure working directory and expose port 80 for Nginx
WORKDIR /var/www/html
EXPOSE 80

# run supervisor
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]