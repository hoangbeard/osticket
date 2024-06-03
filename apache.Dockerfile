FROM php:8.2.19-apache

# Install necessary packages and PHP extensions
RUN apt-get update && apt-get install -y \
    libc-client-dev \
    libkrb5-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libzip-dev \
    libicu-dev \
    libonig-dev \
    libpq-dev \
    libxml2-dev \
    libxslt1-dev \
    libzip-dev \
    zlib1g-dev \
    libgettextpo-dev \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install -j$(nproc) imap \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install opcache intl mysqli pdo pdo_mysql zip \
    && pecl install apcu \
    && docker-php-ext-enable apcu \
    && apt-get clean \
    && a2enmod rewrite

# Use the default production configuration
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Copy Apache configuration
COPY ./apache2/apache2.conf /etc/apache2/apache2.conf
COPY ./apache2/sites-available/000-default.conf /etc/apache2/sites-available/000-default.conf

# Copy application code to the web root
COPY ./app /var/www/html/

# Change document root for Apache
ENV APACHE_DOCUMENT_ROOT /var/www/html
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Set permissions for web root
RUN chown -R www-data:www-data /var/www/html \
    && find /var/www/html -type d -exec chmod 0755 {} \; \
    && find /var/www/html -type f -exec chmod 0664 {} \;

EXPOSE 80

CMD ["apache2-foreground"]