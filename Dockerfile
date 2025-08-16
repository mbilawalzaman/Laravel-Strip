# Base image with PHP, Nginx, FPM
FROM richarvey/nginx-php-fpm:3.1.6

WORKDIR /var/www/html
COPY . .

# PHP & MySQL installation
RUN apk add --no-cache bash git unzip libzip-dev oniguruma-dev \
    mariadb mariadb-client mariadb-server-utils \
    && docker-php-ext-install pdo pdo_mysql mbstring zip

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install Laravel dependencies
RUN composer install --no-dev --optimize-autoloader
RUN chown -R www-data:www-data storage bootstrap/cache

# ✅ Create mysql user/group before preparing directories
RUN addgroup -S mysql && adduser -S mysql -G mysql \
    && mkdir -p /var/lib/mysql /run/mysqld \
    && chown -R mysql:mysql /var/lib/mysql /run/mysqld

EXPOSE 80 3306

# Copy and set startup script
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

CMD ["/usr/local/bin/start.sh"]
