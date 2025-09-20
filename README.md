# Inception - Docker Infrastructure Project

This project sets up a complete web infrastructure with Docker Compose, including Nginx, WordPress and MariaDB.

## 🏗️ Architecture

### Mandatory Services
- **Nginx** : Web server with HTTPS/SSL
- **WordPress** : CMS with PHP 8.2 and WP-CLI
- **MariaDB** : Database
- **Docker Secrets** : Secure password management
- **Volumes** : Data persistence

### Bonus Services
- **Redis** : Cache system for WordPress performance
- **FTP** : File server (vsftpd) for WordPress files
- **Portfolio** : Static website showcasing the project
- **Adminer** : Database administration interface
- **Monitoring** : System monitoring with Netdata

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
# Start everything (mandatory services only)
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

### Bonus commands

```bash
# Start everything with bonus services
make bonus

# Build bonus images
make bonus-build

# Start bonus services
make bonus-up

# Stop bonus services
make bonus-down
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

### Mandatory Services
Once started, the main site is accessible at:
- **HTTPS** : https://localhost:443

### Bonus Services
When using `make bonus`, additional services are available:
- **Portfolio** : http://localhost:3000 - Personal portfolio showcasing the project
- **Adminer** : http://localhost:8080 - Database administration interface
- **Monitoring** : http://localhost:19999 - System monitoring dashboard
- **Redis** : localhost:6379 - Cache server (for applications)
- **FTP** : ftp://localhost:21 - File transfer (credentials: ftpuser/ftppass)

## 📁 Structure

```
inception/
├── Makefile                    # Management commands
├── secrets/                    # Passwords (not versioned)
│   ├── db_password.txt
│   ├── db_root_password.txt
│   └── credentials.txt
└── srcs/
    ├── docker-compose.yml      # Main configuration (mandatory)
    ├── docker-compose-bonus.yml # Bonus configuration
    ├── .env                    # Environment variables
    └── requirements/
        ├── nginx/              # Nginx configuration + SSL
        ├── wordpress/          # WordPress + PHP-FPM
        ├── mariadb/           # Database
        └── bonus/             # Bonus services
            ├── redis/         # Cache system
            ├── ftp/           # FTP server
            ├── portfolio/     # Portfolio website
            ├── adminer/       # Database admin
            └── monitoring/    # System monitoring
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

## 🎁 Bonus Features

The bonus branch includes 5 additional services that extend the basic infrastructure:

### 1. Redis Cache
- **Purpose**: Improves WordPress performance by caching database queries
- **Port**: 6379
- **Integration**: Automatically configured with WordPress

### 2. FTP Server
- **Purpose**: Allows file transfer to WordPress directory
- **Port**: 21 (data ports: 21100-21110)
- **Credentials**: ftpuser / ftppass
- **Access**: Points to WordPress volume for direct file management

### 3. Portfolio Website
- **Purpose**: Personal portfolio showcasing the Inception project
- **Port**: 3000
- **Technology**: Node.js with Express
- **Features**: Responsive design, project information, skills showcase

### 4. Adminer
- **Purpose**: Web-based database administration
- **Port**: 8080
- **Features**: Full MariaDB management, query execution, data visualization
- **Access**: Connect with database credentials from secrets

### 5. System Monitoring
- **Purpose**: Real-time system monitoring and metrics
- **Port**: 19999
- **Technology**: Netdata
- **Features**: CPU, memory, network, and container monitoring

### Bonus Usage
```bash
# Deploy everything with bonus services
make bonus

# Or step by step
make bonus-build    # Build all images including bonus
make bonus-up       # Start all services including bonus
make bonus-down     # Stop all services
```

All bonus services are containerized with custom Dockerfiles and integrate seamlessly with the mandatory infrastructure.