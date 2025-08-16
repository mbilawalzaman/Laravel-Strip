#!/usr/bin/env bash
set -e

echo "Starting MySQL..."
mysqld_safe --datadir=/var/lib/mysql &

# wait for MySQL
sleep 10

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
