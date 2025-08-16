#!/bin/bash
set -e

echo "🚀 Starting MySQL..."
mysqld_safe --datadir='/var/lib/mysql' &

# Wait for MySQL to be ready
until mysqladmin ping --silent; do
    echo "⏳ Waiting for MySQL..."
    sleep 2
done

echo "✅ MySQL is up. Configuring database..."

# Set root password
mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'Xzc123tp@';"

# Create database if not exists
mysql -u root -pXzc123tp@ -e "CREATE DATABASE IF NOT EXISTS stripe_demo;"

# Run Laravel migrations
php /var/www/html/artisan migrate --force

# Cache Laravel config/routes/views
php /var/www/html/artisan config:cache
php /var/www/html/artisan route:cache
php /var/www/html/artisan view:cache

echo "🎉 Laravel setup complete. Starting Nginx + PHP-FPM..."
exec /usr/local/bin/start.sh-nginx
