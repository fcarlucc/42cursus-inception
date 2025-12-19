# Developer Documentation

## Project Overview

This is a Docker-based infrastructure project that sets up a complete web stack with NGINX, WordPress, and MariaDB. All services run in custom-built Docker containers orchestrated by Docker Compose.

---

## Prerequisites

### System Requirements

- **OS**: Linux (Debian/Ubuntu recommended)
- **Docker**: Version 20.10 or higher
- **Docker Compose**: Version 2.0 or higher
- **Make**: GNU Make
- **Sudo privileges**: Required for directory creation in `/home/<your_login>/`

### Installation

```bash
# Install Docker
sudo apt-get update
sudo apt-get install docker.io docker-compose-v2

# Add user to docker group (optional, to avoid using sudo)
sudo usermod -aG docker $USER
```

---

## Project Structure

```
.
├── Makefile                    # Build and deployment automation
├── README.md
├── secrets/                    # Sensitive credentials
│   ├── db_pwd.txt
│   ├── db_root_pwd.txt
│   ├── wp_root_pwd.txt
│   └── wp_user_pwd.txt
└── srcs/
    ├── .env                    # Environment variables
    ├── docker-compose.yml      # Container orchestration
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── conf/
        │   │   └── mariadb-server.cnf
        │   └── tools/
        │       └── entrypoint.sh
        ├── nginx/
        │   ├── Dockerfile
        │   ├── conf/
        │   │   └── nginx.conf
        │   └── tools/
        │       └── entrypoint.sh
        └── wordpress/
            ├── Dockerfile
            ├── conf/
            │   └── www.conf
            └── tools/
                └── entrypoint.sh
```

---

## Setup from Scratch

### 1. Configure Environment Variables

Edit `srcs/.env` to set your configuration:

```bash
# User ID (your 42 login)
UID=<your_login>

# Domain name
DOMAIN_NAME=<your_login>.42.fr

# Database configuration
DB_NAME=wordpress
DB_USER=wp_user

# WordPress configuration
WP_TITLE=My Website
WP_ROOT_USER=<wp_root_username>
WP_ROOT_EMAIL=<your_email@example.com>
WP_USER=<regular_user_username>
WP_USER_EMAIL=<regular_user_email@example.com>
```

### 2. Set Up Secrets

Create and populate files in `secrets/` directory:

```bash
# Database root password
echo "your_secure_root_password" > secrets/db_root_pwd.txt

# Database user password
echo "your_secure_db_password" > secrets/db_pwd.txt

# WordPress root password
echo "your_secure_root_password" > secrets/wp_root_pwd.txt

# WordPress user password
echo "your_secure_user_password" > secrets/wp_user_pwd.txt
```

### 3. Configure Hosts File

Add domain to `/etc/hosts`:

```bash
echo "127.0.0.1 <your_login>.42.fr" | sudo tee -a /etc/hosts
```

---

## Building and Launching

### Using Makefile

The Makefile provides several targets:

```bash
# Build and start (default)
make

# Just start containers
make up

# Stop containers (keeps data)
make down

# Stop containers
make stop

# Start existing containers
make start

# Complete rebuild (cleans data)
make re

# Full cleanup
make fclean

# Clean Docker system
make prune
```

### Using Docker Compose Directly

```bash
# Build images
docker compose -f srcs/docker-compose.yml build

# Start containers
docker compose -f srcs/docker-compose.yml up -d

# Stop containers
docker compose -f srcs/docker-compose.yml down

# View logs
docker compose -f srcs/docker-compose.yml logs -f
```

---

## Container Management

### Accessing Containers

```bash
# Enter NGINX container
docker exec -it nginx bash

# Enter WordPress container
docker exec -it wordpress bash

# Enter MariaDB container
docker exec -it mariadb bash
```

### Managing MariaDB

```bash
# Access MySQL CLI as root
docker exec -it mariadb mysql -u root -p

# Access as WordPress user
docker exec -it mariadb mysql -u wp_user -p wordpress

# Useful SQL queries
USE wordpress;
SHOW TABLES;
SELECT * FROM wp_users;
```

### Viewing Logs

```bash
# All containers
docker compose -f srcs/docker-compose.yml logs

# Specific container
docker logs mariadb
docker logs wordpress
docker logs nginx

# Follow logs in real-time
docker logs -f nginx
```

### Inspecting Containers

```bash
# Container details
docker inspect mariadb

# Container stats
docker stats

# Network information
docker network inspect srcs_inception
```

---

## Volume and Data Management

### Volume Locations

Volumes are mounted from host directories:

- **MariaDB data**: `/home/<your_login>/data/mariadb`
- **WordPress files**: `/home/<your_login>/data/wordpress`

### Managing Volumes

```bash
# List volumes
docker volume ls

# Inspect volume
docker volume inspect srcs_wordpress_db

# Remove volumes (WARNING: deletes data)
docker volume rm srcs_wordpress_db srcs_wordpress_files
```

### Backup Data

```bash
# Backup WordPress files
sudo tar -czf wordpress-backup.tar.gz /home/<your_login>/data/wordpress

# Backup MariaDB database
docker exec mariadb mysqldump -u root -p wordpress > wordpress-backup.sql
```

### Restore Data

```bash
# Restore WordPress files
sudo tar -xzf wordpress-backup.tar.gz -C /

# Restore database
docker exec -i mariadb mysql -u root -p wordpress < wordpress-backup.sql
```

---

## Service-Specific Details

### NGINX

- **Port**: 443 (HTTPS)
- **Config**: `srcs/requirements/nginx/conf/nginx.conf`
- **SSL Certificates**: Generated in entrypoint script
- **Logs**: `/var/log/nginx/` inside container

### WordPress

- **PHP-FPM**: Port 9000
- **Config**: `srcs/requirements/wordpress/conf/www.conf`
- **WP-CLI**: Installed for command-line management
- **Installation**: Automated via entrypoint script

### MariaDB

- **Port**: 3306 (internal network only)
- **Config**: `srcs/requirements/mariadb/conf/mariadb-server.cnf`
- **Database**: wordpress
- **Users**: root, wp_user

---

## Development Workflow

### Making Changes

1. **Edit configuration files** in `srcs/requirements/`
2. **Rebuild specific service**:
   ```bash
   docker compose -f srcs/docker-compose.yml build nginx
   docker compose -f srcs/docker-compose.yml up -d nginx
   ```
3. **Test changes**
4. **Commit to repository**

### Debugging

```bash
# Check if containers are running
docker ps -a

# View real-time logs
docker compose -f srcs/docker-compose.yml logs -f

# Execute commands in container
docker exec -it nginx sh -c "nginx -t"  # Test NGINX config

# Check network connectivity
docker exec wordpress ping mariadb
```

### Clean Development Environment

```bash
# Full cleanup and restart
make re

# Or step by step
make down
sudo rm -rf /home/<your_login>/data/*
make
```

---

## Troubleshooting

### Build Errors

```bash
# Clean Docker cache
docker system prune -a

# Rebuild without cache
docker compose -f srcs/docker-compose.yml build --no-cache
```

### Permission Issues

```bash
# Ensure data directories have correct permissions
sudo chown -R $USER:$USER /home/<your_login>/data/

# Or use sudo for mkdir in Makefile
sudo mkdir -p /home/<your_login>/data/{wordpress,mariadb}
```

### Network Issues

```bash
# Recreate network
docker network rm srcs_inception
make up
```

---

## Best Practices

1. **Never commit secrets** - Keep `secrets/` in `.gitignore`
2. **Use `.env` for configuration** - Avoid hardcoding values
3. **Test locally first** - Before deploying changes
4. **Backup before `make re`** - This deletes all data
5. **Check logs regularly** - Use `docker logs` to monitor services
6. **Document changes** - Update this file when modifying architecture
