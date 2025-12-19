#!/bin/bash

# Exit on any error
set -e

# Read secrets from Docker secrets files
DB_ROOT_PASSWORD=$(cat /run/secrets/DB_ROOT_PASSWORD)
DB_PASSWORD=$(cat /run/secrets/DB_PASSWORD)

echo "Starting MariaDB setup..."

# Create required directories
mkdir -p /var/lib/mysql /run/mysqld
chown -R mysql:mysql /var/lib/mysql /run/mysqld

# Check if database directory exists
if [ -d "/var/lib/mysql/mysql" ]; then
    echo "Database already exists, skipping initialization"
else
    echo "Database does not exist, initializing..."
fi

# Initialize database if it doesn't exist
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB database..."
    
    # Initialize the database as mysql user
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql --skip-test-db
    
    # Start MariaDB temporarily (no networking for security during setup)
    mariadbd --user=mysql --datadir=/var/lib/mysql --skip-networking &
    pid=$!
    
    # Wait for MariaDB to start
    for i in {1..30}; do
        if mariadb-admin ping --silent 2>/dev/null; then
            break
        fi
        echo "Waiting for MariaDB to start..."
        sleep 1
    done
    
    echo "Setting up database and users..."
    
    # Run all setup commands in a single session
    mariadb <<-EOSQL
		SET @@SESSION.SQL_LOG_BIN=0;
		DELETE FROM mysql.user WHERE user NOT IN ('mysql.sys', 'mariadb.sys', 'root') OR host NOT IN ('localhost');
		ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
		CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
		CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
		GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
		FLUSH PRIVILEGES;
	EOSQL
    
    # Stop the temporary instance
    mariadb-admin shutdown
    wait $pid
    
    echo "Database setup completed!"
fi

echo "Starting MariaDB server..."
exec mariadbd --user=mysql --datadir=/var/lib/mysql