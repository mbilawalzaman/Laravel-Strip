FROM richarvey/nginx-php-fpm:3.1.6

# Copy app files
COPY . /var/www/html

# Copy custom start script
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

# Environment setup
ENV SKIP_COMPOSER 1
ENV WEBROOT /var/www/html/public
ENV PHP_ERRORS_STDERR 1
ENV RUN_SCRIPTS 1
ENV REAL_IP_HEADER 1
ENV APP_ENV production
ENV APP_DEBUG false
ENV LOG_CHANNEL stderr

# Install dependencies
RUN composer install --no-dev --optimize-autoloader \
    && chown -R nginx:nginx /var/www/html

# Prepare MySQL data directories
RUN mkdir -p /var/lib/mysql /run/mysqld \
    && chown -R mysql:mysql /var/lib/mysql /run/mysqld

# Expose ports
EXPOSE 80 443

# Start script
CMD ["/usr/local/bin/start.sh"]
