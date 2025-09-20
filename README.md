# Inception - Docker Infrastructure Project

This project sets up a complete web infrastructure with Docker Compose, including Nginx, WordPress and MariaDB.

## 🏗️ Architecture

- **Nginx** : Web server with HTTPS/SSL
- **WordPress** : CMS with PHP 8.2 and WP-CLI
- **MariaDB** : Database
- **Docker Secrets** : Secure password management
- **Volumes** : Data persistence

## 🚀 Installation

### Prerequisites
- Docker and Docker Compose
- Make

### Configuration

1. **Clone the project:**
```bash
git clone https://github.com/Maj-e/inception.git
cd inception
```

2. **Configure environment:**
```bash
cp srcs/.env.example srcs/.env
# Edit srcs/.env with your values
```

3. **Create secrets:**
```bash
mkdir secrets
echo "your_db_password" > secrets/db_password.txt
echo "your_root_password" > secrets/db_root_password.txt
echo "admin_user:admin_password" > secrets/credentials.txt
echo "second_user:user_password" >> secrets/credentials.txt
```

## 🎯 Usage

### Main commands

```bash
# Start everything
make

# Build images
make build

# Start services
make up

# Stop services
make down

# Clean (keep images/volumes)
make clean

# Clean completely
make fclean

# Restart from scratch
make re
```

### Individual services

```bash
# Manage a specific service
make nginx
make wordpress  
make mariadb
```

### Information and debug

```bash
# View logs
make logs

# Container status
make ps

# System information
make info

# Docker Compose configuration
make config
```

## 🌐 Access

Once started, the site is accessible at:
- **HTTPS** : https://localhost:443

## 📁 Structure

```
inception/
├── Makefile              # Management commands
├── secrets/              # Passwords (not versioned)
│   ├── db_password.txt
│   ├── db_root_password.txt
│   └── credentials.txt
└── srcs/
    ├── docker-compose.yml # Main configuration
    ├── .env              # Environment variables
    └── requirements/
        ├── nginx/        # Nginx configuration + SSL
        ├── wordpress/    # WordPress + PHP-FPM
        └── mariadb/      # Database
```

## 🔒 Security

- ✅ Docker Secrets for passwords
- ✅ HTTPS only (TLSv1.2/1.3)
- ✅ Self-signed SSL certificates
- ✅ No hardcoded passwords in code
- ✅ Dedicated users for each service

## 📝 Notes

- The configured domain is `mjeannin.42.es` (changeable in `.env`)
- Data volumes are persistent in `/home/mjeannin/data/`
- WordPress is configured with WP-CLI for automation
- Database created automatically on first startup

## 🛠️ Development

For development or debugging:
- Logs are accessible via `make logs`
- Configuration testable with `make config`
- Each service can be built/tested individually