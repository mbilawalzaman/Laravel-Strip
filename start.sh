#!/bin/sh
set -e

echo "🚀 Starting container..."

# ✅ Ensure MySQL data directory exists with correct permissions
if [ ! -d "/var/lib/mysql/mysql" ]; then
  echo "Initializing MySQL data directory..."
  mysql_install_db --user=mysql --ldata=/var/lib/mysql > /dev/null
fi

# ✅ Start MySQL in the background
echo "Starting MySQL..."
mysqld_safe --user=mysql --datadir=/var/lib/mysql &

# ✅ Wait for MySQL TCP connections to be ready
echo "⏳ Waiting for MySQL to accept TCP connections..."
until mysqladmin ping -h 127.0.0.1 -P 3306 -u root -pXzc123tp@ --silent; do
  sleep 2
done
echo "✅ MySQL TCP is ready!"

# ✅ Apply database and user privileges
echo "🔧 Setting up database and user..."
mysql -h 127.0.0.1 -P 3306 -u root -pXzc123tp@ -e "
CREATE DATABASE IF NOT EXISTS stripe_demo;
GRANT ALL PRIVILEGES ON stripe_demo.* TO 'root'@'localhost' IDENTIFIED BY 'Xzc123tp@';
FLUSH PRIVILEGES;
"

# ✅ Run Composer install
echo "📦 Installing Composer dependencies..."
composer install --no-dev --working-dir=/var/www/html --optimize-autoloader

# ✅ Cache Laravel configuration and routes
echo "⚡ Caching Laravel config and routes..."
php artisan config:cache
php artisan route:cache

# ✅ Run Laravel migrations
echo "🗄️ Running Laravel migrations..."
php artisan migrate --force

# ✅ Start PHP-FPM
echo "Starting PHP-FPM..."
php-fpm &

# ✅ Start Nginx in foreground
echo "🌐 Starting Nginx..."
nginx -g "daemon off;"
