FROM richarvey/nginx-php-fpm:3.1.6

WORKDIR /var/www/html
COPY . .

ENV SKIP_COMPOSER 1
ENV WEBROOT /var/www/html/public
ENV PHP_ERRORS_STDERR 1
ENV RUN_SCRIPTS 1
ENV REAL_IP_HEADER 1
ENV APP_ENV production
ENV APP_DEBUG false
ENV LOG_CHANNEL stderr
ENV COMPOSER_ALLOW_SUPERUSER 1

RUN apk add --no-cache bash git unzip libzip-dev oniguruma-dev mariadb mariadb-client mariadb-server-utils \
    && docker-php-ext-install pdo pdo_mysql mbstring zip

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
RUN composer install --no-dev --optimize-autoloader
RUN chown -R www-data:www-data storage bootstrap/cache

# MySQL setup (if running inside same container — not recommended)
RUN mkdir -p /var/lib/mysql /run/mysqld && \
    chown -R mysql:mysql /var/lib/mysql /run/mysqld && \
    mysql_install_db --user=mysql --ldata=/var/lib/mysql

ENV MYSQL_ROOT_PASSWORD=Xzc123tp@
ENV MYSQL_DATABASE=stripe_demo
ENV MYSQL_USER=root
ENV MYSQL_PASSWORD=Xzc123tp@

COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

EXPOSE 80 3306
CMD ["/usr/local/bin/start.sh"]
