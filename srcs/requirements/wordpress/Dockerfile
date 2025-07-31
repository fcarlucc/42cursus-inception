FROM debian:bullseye

# Install PHP-FPM, PHP extensions, curl, and clean up
RUN apt-get update && \
    apt-get install -y \
        php7.4-fpm \
        php7.4-mysql \
        php7.4-curl \
        php7.4-gd \
        php7.4-xml \
        php7.4-mbstring \
        php7.4-zip \
        php7.4-intl \
        curl \
        mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# Create necessary directories
RUN mkdir -p /var/www/html && \
    mkdir -p /run/php && \
    mkdir -p /var/log/php

# Download and install WP-CLI (WordPress Command Line Interface)
RUN curl -O https://raw.githubusercontent.com/wp-cli/wp-cli/v2.8.1/bin/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Copy PHP-FPM configuration if needed
# COPY conf/php-fpm.conf /etc/php/7.4/fpm/php-fpm.conf

# Copy entrypoint script
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose PHP-FPM port for internal communication with NGINX
EXPOSE 9000

# Start WordPress setup
CMD ["/usr/local/bin/entrypoint.sh"]