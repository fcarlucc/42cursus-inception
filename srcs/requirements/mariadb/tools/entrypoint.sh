#!/bin/bash

# Exit on any error
set -e

echo "Starting MariaDB setup..."

# Initialize database if it doesn't exist
if [ ! -d "/var/lib/mariadb/mysql" ]; then
    echo "Initializing MariaDB database..."
    
    # Initialize the database
    mariadb-install-db --datadir=/var/lib/mariadb
    
    # Start MariaDB in safe mode temporarily
    mariadbd-safe --datadir=/var/lib/mariadb &
    mariadb_pid=$!
    
    # Wait for MariaDB to be ready
    until mariadb-admin ping --silent; do
        echo "Waiting for MariaDB to be ready..."
        sleep 2
    done
    
    # Read environment variables for database setup
    echo "Setting up database and users..."
    
    # Set root password
    mariadb -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';"
    
    # Create database
    mariadb -u root -p"${DB_ROOT_PASSWORD}" -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME};"
    
    # Create database
    mariadb -u root -p"${DB_ROOT_PASSWORD}" -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME};"
    
    # Create WordPress database user
    mariadb -u root -p"${DB_ROOT_PASSWORD}" -e "CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';"
    mariadb -u root -p"${DB_ROOT_PASSWORD}" -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';"
    
    mariadb -u root -p"${DB_ROOT_PASSWORD}" -e "FLUSH PRIVILEGES;"
    
    # Stop the temporary MariaDB instance
    mariadb-admin -u root -p"${DB_ROOT_PASSWORD}" shutdown
    wait $mariadb_pid
    
    echo "Database setup completed!"
fi

echo "Starting MariaDB server..."
# Start MariaDB (this keeps the container running as PID 1)
exec mariadbd --datadir=/var/lib/mariadb