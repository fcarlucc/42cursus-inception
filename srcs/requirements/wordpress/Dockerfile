FROM debian:bookworm

# Install PHP-FPM, PHP extensions, curl, and clean up
RUN apt-get update && \
    apt-get install -y \
        php8.2-fpm \
        php8.2-mysql \
        php8.2-curl \
        php8.2-gd \
        php8.2-xml \
        php8.2-mbstring \
        php8.2-zip \
        php8.2-intl \
        curl \
        mariadb-client \
        msmtp \
        msmtp-mta \
    && rm -rf /var/lib/apt/lists/*

# Create necessary directories
RUN mkdir -p /var/www/html && \
    mkdir -p /run/php && \
    mkdir -p /var/log/php

# Download and install WP-CLI (WordPress Command Line Interface)
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Copy PHP-FPM pool configuration
COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

# Copy entrypoint script
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose PHP-FPM port for internal communication with NGINX
EXPOSE 9000

# Start WordPress setup
CMD ["/usr/local/bin/entrypoint.sh"]