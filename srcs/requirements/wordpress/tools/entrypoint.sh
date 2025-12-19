#!/bin/bash

# Exit on any error
set -e

# Read secrets from Docker secrets files
DB_PASSWORD=$(cat /run/secrets/DB_PASSWORD)
WP_ROOT_PASSWORD=$(cat /run/secrets/WP_ROOT_PASSWORD)
WP_USER_PASSWORD=$(cat /run/secrets/WP_USER_PASSWORD)

echo "Starting WordPress setup..."

# Wait for MariaDB to be ready
echo "Waiting for MariaDB to be available..."
until mariadb -h mariadb -u"${DB_USER}" -p"${DB_PASSWORD}" -e "SELECT 1" >/dev/null 2>&1; do
    echo "MariaDB is not ready yet. Waiting..."
    sleep 2
done
echo "MariaDB is ready!"

# Change to WordPress directory
cd /var/www/html

# Download WordPress if not already present
if [ ! -f wp-config.php ]; then
    echo "Downloading WordPress..."
    wp core download --allow-root
    
    echo "Creating wp-config.php..."
    wp config create \
        --dbname="${DB_NAME}" \
        --dbuser="${DB_USER}" \
        --dbpass="${DB_PASSWORD}" \
        --dbhost="mariadb" \
        --allow-root
    
    echo "Installing WordPress..."
    wp core install \
        --url="https://${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ROOT_USER}" \
        --admin_password="${WP_ROOT_PASSWORD}" \
        --admin_email="${WP_ROOT_EMAIL}" \
        --allow-root
    
    echo "Creating additional WordPress user..."
    wp user create \
        "${WP_USER}" \
        "${WP_USER_EMAIL}" \
        --user_pass="${WP_USER_PASSWORD}" \
        --role="author" \
        --allow-root
    
    echo "WordPress setup completed!"
else
    echo "WordPress already configured, skipping setup."
fi

# Set proper permissions
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

echo "Starting PHP-FPM..."
# Start PHP-FPM in foreground (required for Docker PID 1)
exec php-fpm8.2 -F