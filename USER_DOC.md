# User Documentation

## Overview

This project provides a complete web infrastructure stack using Docker containers, consisting of:

- **NGINX**: Web server with SSL/TLS encryption
- **WordPress**: Content Management System (CMS)
- **MariaDB**: Database server for WordPress

All services run in isolated Docker containers and communicate through a dedicated network.

---

## Starting and Stopping the Project

### Start the project

```bash
make
```

This command will:
1. Create necessary data directories
2. Build Docker images
3. Start all containers

### Stop the project

```bash
make down
```

This stops all containers but preserves volumes and data.

### Restart with rebuild

```bash
make re
```

This command will:
1. Stop and remove all containers
2. Clean all data
3. Recreate directories
4. Rebuild and start everything from scratch

### Other useful commands

```bash
make stop    # Stop containers without removing them
make start   # Start existing containers
make fclean  # Complete cleanup (removes all data)
```

---

## Accessing the Services

### Website

Access the WordPress website at:
- **URL**: https://<your_login>.42.fr
- The connection is secured with SSL/TLS

> **Note**: You may need to add `<your_login>.42.fr` to your `/etc/hosts` file pointing to `127.0.0.1`

### WordPress Administration Panel

Access the root panel at:
- **URL**: https://<your_login>.42.fr/wp-root
- **Username**: `<wp_root_username>` (see `srcs/.env`)
- **Password**: See `secrets/wp_root_pwd.txt`

---

## Managing Credentials

All credentials are stored in the `secrets/` directory:

| File | Description |
|------|-------------|
| `secrets/db_root_pwd.txt` | MariaDB root password |
| `secrets/db_pwd.txt` | WordPress database user password |
| `secrets/wp_root_pwd.txt` | WordPress root password |
| `secrets/wp_user_pwd.txt` | WordPress regular user password |

### Changing Credentials

1. Edit the appropriate file in `secrets/`
2. Run `make re` to rebuild with new credentials

---

## Checking Services Status

### Check running containers

```bash
docker ps
```

You should see three containers:
- `nginx`
- `wordpress`
- `mariadb`

### Check container logs

```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
```

### Check if services respond

```bash
# Test NGINX
curl -k https://<your_login>.42.fr

# Check MariaDB connection
docker exec -it mariadb mysql -u root -p
```

### Verify volumes

```bash
docker volume ls
```

You should see:
- `srcs_wordpress_db`
- `srcs_wordpress_files`

---

## Data Persistence

All persistent data is stored in:
- `/home/<your_login>/data/wordpress` - WordPress files
- `/home/<your_login>/data/mariadb` - Database files

This data persists across container restarts unless you run `make fclean` or `make re`.

---

## Troubleshooting

### Cannot access the website

1. Check containers are running: `docker ps`
2. Check NGINX logs: `docker logs nginx`
3. Verify `/etc/hosts` contains: `127.0.0.1 <your_login>.42.fr`

### Database connection errors

1. Check MariaDB is running: `docker ps | grep mariadb`
2. Check MariaDB logs: `docker logs mariadb`
3. Verify credentials in `secrets/db_pwd.txt`

### Containers won't start

1. Check Docker service: `sudo systemctl status docker`
2. Remove old containers: `make fclean`
3. Start fresh: `make re`
