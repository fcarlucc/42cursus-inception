FROM debian:bullseye

# Install MariaDB server and clean up apt cache
RUN apt-get update && \
    apt-get install -y mariadb-server && \
    rm -rf /var/lib/apt/lists/*

# Create necessary directories
RUN mkdir -p /var/run/mysqld && \
    mkdir -p /var/lib/mariadb

# Copy configuration file
COPY conf/mariadb.cnf /etc/mysql/mariadb.cnf

# Copy entrypoint script and add execute permissions
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose MySQL port only for internal communication not to the host
EXPOSE 3306

# Start MariaDB
CMD ["/usr/local/bin/entrypoint.sh"]