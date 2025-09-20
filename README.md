# Inception - Docker Infrastructure Project

Ce projet met en place une infrastructure web complète avec Docker Compose, incluant Nginx, WordPress et MariaDB.

## 🏗️ Architecture

- **Nginx** : Serveur web avec HTTPS/SSL
- **WordPress** : CMS avec PHP 8.2 et WP-CLI
- **MariaDB** : Base de données
- **Docker Secrets** : Gestion sécurisée des mots de passe
- **Volumes** : Persistance des données

## 🚀 Installation

### Prérequis
- Docker et Docker Compose
- Make

### Configuration

1. **Cloner le projet :**
```bash
git clone git@github.com:Maj-e/inception.git
cd inception
```

2. **Configurer l'environnement :**
```bash
cp srcs/.env.example srcs/.env
# Éditer srcs/.env avec vos valeurs
```

3. **Créer les secrets :**
```bash
mkdir secrets
echo "your_db_password" > secrets/db_password.txt
echo "your_root_password" > secrets/db_root_password.txt
echo "admin_user:admin_password" > secrets/credentials.txt
echo "second_user:user_password" >> secrets/credentials.txt
```

## 🎯 Utilisation

### Commandes principales

```bash
# Démarrer tout
make

# Construire les images
make build

# Démarrer les services
make up

# Arrêter les services
make down

# Nettoyer (garder images/volumes)
make clean

# Nettoyer complètement
make fclean

# Redémarrer depuis zéro
make re
```

### Services individuels

```bash
# Gérer un service spécifique
make nginx
make wordpress  
make mariadb
```

### Information et debug

```bash
# Voir les logs
make logs

# Statut des containers
make ps

# Informations système
make info

# Configuration Docker Compose
make config
```

## 🌐 Accès

Une fois démarré, le site est accessible sur :
- **HTTPS** : https://localhost:443

## 📁 Structure

```
inception/
├── Makefile              # Commandes de gestion
├── secrets/              # Mots de passe (non versionné)
│   ├── db_password.txt
│   ├── db_root_password.txt
│   └── credentials.txt
└── srcs/
    ├── docker-compose.yml # Configuration principale
    ├── .env              # Variables d'environnement
    └── requirements/
        ├── nginx/        # Configuration Nginx + SSL
        ├── wordpress/    # WordPress + PHP-FPM
        └── mariadb/      # Base de données
```

## 🔒 Sécurité

- ✅ Docker Secrets pour les mots de passe
- ✅ HTTPS uniquement (TLSv1.2/1.3)
- ✅ Certificats SSL auto-signés
- ✅ Pas de mots de passe en dur dans le code
- ✅ Utilisateurs dédiés pour chaque service

## 📝 Notes

- Le domaine configuré est `mjeannin.42.es` (modifiable dans `.env`)
- Les volumes de données sont persistants dans `/home/mjeannin/data/`
- WordPress est configuré avec WP-CLI pour l'automatisation
- Base de données créée automatiquement au premier démarrage

## 🛠️ Développement

Pour le développement ou le debug :
- Les logs sont accessibles via `make logs`
- Configuration testable avec `make config`
- Chaque service peut être construit/testé individuellement