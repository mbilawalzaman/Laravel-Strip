#!/usr/bin/env bash
set -e

echo "Starting MySQL..."
mysqld_safe --datadir=/var/lib/mysql &

# wait for MySQL to accept connections
echo "Waiting for MySQL to be ready..."
until mysqladmin ping -u root --silent; do
  sleep 2
done

echo "Creating database and user if not exists..."
mysql -u root -e "CREATE DATABASE IF NOT EXISTS stripe_demo;"
mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'Xzc123tp@';"
mysql -u root -pXzc123tp@ -e "GRANT ALL PRIVILEGES ON stripe_demo.* TO 'root'@'localhost'; FLUSH PRIVILEGES;"

echo "Running composer..."
composer install --no-dev --working-dir=/var/www/html

echo "Caching config..."
php artisan config:cache

echo "Caching routes..."
php artisan route:cache

echo "Running migrations..."
php artisan migrate --force

echo "Starting Nginx + PHP-FPM..."
/start.sh
