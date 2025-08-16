# Base image
FROM richarvey/nginx-php-fpm:3.1.6

# Set working directory
WORKDIR /var/www/html

# Copy project files
COPY . .

# Image config
ENV SKIP_COMPOSER 1
ENV WEBROOT /var/www/html/public
ENV PHP_ERRORS_STDERR 1
ENV RUN_SCRIPTS 1
ENV REAL_IP_HEADER 1

# Laravel config
ENV APP_ENV production
ENV APP_DEBUG false
ENV LOG_CHANNEL stderr

# Allow composer to run as root
ENV COMPOSER_ALLOW_SUPERUSER 1

# Install PHP extensions Laravel needs + MySQL server
RUN apk add --no-cache bash git unzip libzip-dev oniguruma-dev \
    mariadb mariadb-client mariadb-server-utils \
    && docker-php-ext-install pdo pdo_mysql mbstring zip

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install Laravel dependencies
RUN composer install --no-dev --optimize-autoloader

# Set proper permissions for storage & cache
RUN chown -R www-data:www-data storage bootstrap/cache

# Create MySQL data directory
RUN mkdir -p /var/lib/mysql /run/mysqld && \
    chown -R mysql:mysql /var/lib/mysql /run/mysqld

# Initialize MySQL with default DB/user for Laravel
RUN mysql_install_db --user=mysql --ldata=/var/lib/mysql

ENV MYSQL_ROOT_PASSWORD=rootpass
ENV MYSQL_DATABASE=laravel
ENV MYSQL_USER=laravel
ENV MYSQL_PASSWORD=laravelpass

# Add a startup script to run both MySQL + nginx + php-fpm
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

# Expose ports
EXPOSE 80 3306

# Start everything
CMD ["/usr/local/bin/start.sh"]
