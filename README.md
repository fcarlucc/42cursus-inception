# Inception

*This project has been created as part of the 42 curriculum by fcarlucc.*

---

## Description

**Inception** is a system administration and virtualization project that requires setting up a complete web infrastructure using Docker. The goal is to deploy a small-scale production environment running WordPress with NGINX as a reverse proxy and MariaDB as the database server.

This project emphasizes:
- Containerization and orchestration with Docker and Docker Compose
- Security best practices (SSL/TLS, secrets management)
- Service isolation and networking
- Data persistence with volumes
- Infrastructure as Code principles

The entire infrastructure runs on custom-built Docker images (no pre-made images like Alpine or official WordPress images are allowed, except for the base Debian OS).

---

## Instructions

### Prerequisites

- Docker (version 20.10+)
- Docker Compose (version 2.0+)
- Make
- Linux environment (tested on Debian/Ubuntu)
- Sudo privileges

### Installation and Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd 42cursus-inception
   ```

2. **Configure the domain name**
   
   Add the following line to `/etc/hosts`:
   ```bash
   echo "127.0.0.1 <your_login>.42.fr" | sudo tee -a /etc/hosts
   ```

3. **Set up secrets** (if not already present)
   
   Ensure the `secrets/` directory contains:
   - `db_root_pwd.txt` - MariaDB root password
   - `db_pwd.txt` - WordPress database user password
   - `wp_root_pwd.txt` - WordPress root password
   - `wp_user_pwd.txt` - WordPress user password

4. **Build and run the project**
   ```bash
   make
   ```

### Usage

| Command | Description |
|---------|-------------|
| `make` or `make all` | Create directories and start all services |
| `make up` | Build and start containers |
| `make down` | Stop and remove containers (preserves data) |
| `make stop` | Stop containers without removing them |
| `make start` | Start existing containers |
| `make re` | Complete rebuild (removes all data) |
| `make fclean` | Full cleanup |
| `make prune` | Clean Docker system |

### Accessing the Services

- **Website**: https://<your_login>.42.fr
- **WordPress Root**: https://<your_login>.42.fr/wp-admin
  - Username: `<wp_root_username>` (see `srcs/.env`)
  - Password: see `secrets/wp_root_pwd.txt`

### Documentation

For detailed documentation, see:
- [USER_DOC.md](USER_DOC.md) - User and administrator guide
- [DEV_DOC.md](DEV_DOC.md) - Developer documentation

---

## Project Description

### Docker Architecture

This project uses **Docker** to create isolated, reproducible environments for each service. The infrastructure consists of three main containers:

1. **NGINX** - Web server and reverse proxy with SSL/TLS
2. **WordPress** - Content management system with PHP-FPM
3. **MariaDB** - Relational database server

Each service runs in its own container with custom-built Dockerfiles based on Debian, ensuring complete control over the environment and dependencies.

#### Container Communication

Services communicate through a dedicated Docker network (`inception`), isolating them from the host and other containers. NGINX acts as the entry point, proxying requests to WordPress via PHP-FPM on port 9000.

#### Data Persistence

Persistent data is stored using Docker volumes with bind mounts to the host filesystem:
- `/home/<your_login>/data/mariadb` - Database files
- `/home/<your_login>/data/wordpress` - WordPress installation and uploads

### Design Choices

#### Virtual Machines vs Docker

| Aspect | Virtual Machines | Docker (Our Choice) |
|--------|-----------------|---------------------|
| **Resource Usage** | Heavy - full OS per VM | Lightweight - shared kernel |
| **Startup Time** | Minutes | Seconds |
| **Isolation** | Complete hardware virtualization | Process-level isolation |
| **Portability** | Large image files (GBs) | Small images (MBs) |
| **Use Case** | Different OS requirements | Same kernel, isolated services |

**Why Docker?** For this project, Docker provides sufficient isolation while being more efficient and portable. Each service needs only its specific dependencies, not a full operating system.

#### Secrets vs Environment Variables

| Aspect | Secrets (Our Choice) | Environment Variables |
|--------|---------------------|----------------------|
| **Security** | Not stored in process environment | Visible in `docker inspect` and logs |
| **File System** | Mounted as read-only files | Exposed as env vars |
| **Rotation** | Easier to update without rebuild | Requires container restart |
| **Best Practice** | Recommended for sensitive data | Suitable for non-sensitive config |

**Why Secrets?** Docker secrets are more secure for storing passwords and credentials. They are:
- Encrypted at rest and in transit
- Only available to specific services
- Not visible in container metadata
- Mounted as temporary files in memory

#### Docker Network vs Host Network

| Aspect | Docker Network (Our Choice) | Host Network |
|--------|----------------------------|--------------|
| **Isolation** | Services isolated from host | Direct access to host network |
| **Port Conflicts** | No conflicts between containers | Must avoid port conflicts |
| **Security** | Better isolation | Less secure |
| **DNS** | Built-in service discovery | Manual configuration needed |

**Why Docker Network?** A custom bridge network (`inception`) provides:
- Automatic DNS resolution between containers (e.g., `wordpress` can reach `mariadb` by name)
- Network isolation from other containers and the host
- Controlled exposure of services (only NGINX port 443 is exposed)

#### Docker Volumes vs Bind Mounts

| Aspect | Docker Volumes | Bind Mounts (Our Choice) |
|--------|---------------|--------------------------|
| **Management** | Docker-managed | User-managed paths |
| **Portability** | More portable | Tied to host paths |
| **Permissions** | Easier to manage | Can have permission issues |
| **Backup** | Need Docker commands | Direct file system access |

**Why Bind Mounts?** For this project, bind mounts to `/home/<your_login>/data/` provide:
- Direct access to data for backups and inspection
- Explicit control over data location
- Easy integration with host file system tools
- Requirement compliance (subject specifies host path)

### Project Structure

```
.
├── Makefile                        # Automation for build/deploy
├── README.md                       # This file
├── USER_DOC.md                     # User documentation
├── DEV_DOC.md                      # Developer documentation
├── secrets/                        # Sensitive credentials (gitignored)
│   ├── db_pwd.txt
│   ├── db_root_pwd.txt
│   ├── wp_root_pwd.txt
│   └── wp_user_pwd.txt
└── srcs/
    ├── .env                        # Environment configuration
    ├── docker-compose.yml          # Service orchestration
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile          # MariaDB image definition
        │   ├── conf/
        │   │   └── mariadb-server.cnf
        │   └── tools/
        │       └── entrypoint.sh   # Initialization script
        ├── nginx/
        │   ├── Dockerfile          # NGINX image definition
        │   ├── conf/
        │   │   └── nginx.conf      # NGINX configuration
        │   └── tools/
        │       └── entrypoint.sh   # SSL setup script
        └── wordpress/
            ├── Dockerfile          # WordPress image definition
            ├── conf/
            │   └── www.conf        # PHP-FPM configuration
            └── tools/
                └── entrypoint.sh   # WordPress setup script
```

### Technical Implementation

#### NGINX Container
- Base: Debian latest
- Generates self-signed SSL certificate on startup
- Configured for TLSv1.2 and TLSv1.3
- Proxies PHP requests to WordPress container
- Serves static files directly

#### WordPress Container
- Base: Debian latest
- PHP 8.2 with PHP-FPM
- WP-CLI for command-line management
- Automatic WordPress installation on first run
- Creates root and regular user accounts

#### MariaDB Container
- Base: Debian latest
- MariaDB 10.11
- Configured for remote connections from WordPress
- Automatic database and user creation
- Data persistence via bind mount

---

## Resources

### Documentation
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [WordPress CLI](https://wp-cli.org/)
- [MariaDB Documentation](https://mariadb.com/kb/en/documentation/)
- [Docker Security Best Practices](https://docs.docker.com/engine/security/)

### Tutorials
- [Docker Networking Tutorial](https://docs.docker.com/network/network-tutorial-standalone/)
- [Docker Volumes Tutorial](https://docs.docker.com/storage/volumes/)
- [NGINX SSL Configuration](https://nginx.org/en/docs/http/configuring_https_servers.html)

### Articles
- [Docker vs Virtual Machines](https://www.docker.com/resources/what-container/)
- [Managing Secrets in Docker](https://docs.docker.com/engine/swarm/secrets/)
- [PHP-FPM with NGINX](https://www.nginx.com/resources/wiki/start/topics/examples/phpfcgi/)

### AI Usage

AI tools were used as a reference and debugging assistant throughout the project development:
- Documentation support
- Configuration guidance
- Troubleshooting assistance

**Note**: All core implementation decisions, architecture design, Dockerfile creation, and service configuration were done independently.

---

## Features

- ✅ Custom Docker images (no pre-made containers)
- ✅ SSL/TLS encryption (HTTPS only)
- ✅ Secure secrets management
- ✅ Isolated Docker network
- ✅ Persistent data storage
- ✅ Automated WordPress installation
- ✅ Multi-user WordPress setup
- ✅ Health checks and restart policies
- ✅ Comprehensive documentation

---

## License

This project is part of the 42 School curriculum and is intended for educational purposes.

---

## Author

**fcarlucc** - 42 Student

For questions or issues, please refer to the documentation files or contact the author.
