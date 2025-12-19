FROM debian:bookworm

# Install NGINX and OpenSSL for self-signed certificates and clean up apt cache
RUN apt-get update && \
    apt-get install -y nginx openssl && \
    rm -rf /var/lib/apt/lists/*

# Create necessary directories
RUN mkdir -p /var/www/html && \
    mkdir -p /etc/nginx/ssl && \
    mkdir -p /var/log/nginx

# Copy NGINX configuration
COPY conf/nginx.conf /etc/nginx/nginx.conf

# Copy entrypoint script
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose HTTPS port only (as required by subject)
EXPOSE 443

# Start NGINX
CMD ["/usr/local/bin/entrypoint.sh"]