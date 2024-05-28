FROM hoangbeard/nginx-php-fpm:nginx1.26.0-php8.2.19-fpm-alpine3.19

COPY ./app .

RUN chown -R www-data:www-data /var/www/html \
    && chmod 2775 /var/www/html && find /var/www/html -type d -exec chmod 2775 {} \;
RUN find /var/www/html -type f -exec chmod 0664 {} \;
