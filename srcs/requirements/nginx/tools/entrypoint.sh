#!/bin/bash

# Exit on any error
set -e

echo "Starting NGINX setup..."

# Generate SSL certificate if it doesn't exist
if [ ! -f "/etc/nginx/ssl/inception.crt" ]; then
    echo "Generating SSL certificate..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/inception.key \
        -out /etc/nginx/ssl/inception.crt \
        -subj "/C=IT/ST=Italy/L=Rome/O=42School/OU=Student/CN=${DOMAIN_NAME}/UID=${UID}"
    echo "SSL certificate generated successfully!"
else
    echo "SSL certificate already exists, skipping generation."
fi

# Test NGINX configuration
echo "Testing NGINX configuration..."
nginx -t

# Create required directories if they don't exist
mkdir -p /var/www/html
mkdir -p /var/log/nginx

# Set proper permissions for web directory
chmod 755 /var/www/html
chown -R www-data:www-data /var/www/html

echo "NGINX configuration is valid!"
echo "Starting NGINX server..."

# Start NGINX in foreground (required for Docker PID 1)
exec nginx -g "daemon off;"