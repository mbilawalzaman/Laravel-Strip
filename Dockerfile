# Base image with PHP, Nginx, FPM
FROM richarvey/nginx-php-fpm:3.1.6

# Set working directory
WORKDIR /var/www/html

# Copy project files
COPY . .

# Install PHP extensions & necessary tools
RUN apk add --no-cache bash git unzip libzip-dev oniguruma-dev mariadb mariadb-client mariadb-server-utils \
    && docker-php-ext-install pdo pdo_mysql mbstring zip

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Ensure storage & cache permissions
RUN chown -R www-data:www-data storage bootstrap/cache

# Ensure MySQL user exists and prepare directories
RUN adduser -S -G mysql mysql || true \
    && mkdir -p /var/lib/mysql /run/mysqld \
    && chown -R mysql:mysql /var/lib/mysql /run/mysqld

# Copy and set startup script
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

# Expose HTTP port
EXPOSE 80

# Entrypoint runs start.sh (starts MySQL, PHP-FPM, Nginx, Composer, migrations)
ENTRYPOINT ["/usr/local/bin/start.sh"]
