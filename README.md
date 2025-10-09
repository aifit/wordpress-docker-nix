# WordPress + MariaDB (Local Development)

This repository provides a **local WordPress development environment** powered by **Docker** and optionally managed through **Nix Flakes**.

---

## ⚠️ Disclaimer

This setup is for **local development only**.
Do **not** use this configuration in production without proper hardening, SSL, and security adjustments.

---

## 🗂 Folder Structure

```
.
├── wp-content/          # WordPress content folder (themes, plugins, uploads)
├── env.sample           # Example environment file to copy and rename as `.env`
├── .gitignore
├── docker-compose.yml   # Main Docker Compose file
├── flake.nix            # Nix flake for reproducible dev environment
├── flake.lock
└── README.md
```

---

## ⚙️ Environment Setup

### 1. Copy `.env`

Start by copying the example environment file:

```bash
cp env.sample .env
```

Then edit `.env` as needed. Example variables:

```env
HOST_PORT=8081
WORDPRESS_DB_HOST=db
WORDPRESS_DB_USER=wp_user
WORDPRESS_DB_PASSWORD=wp_password
WORDPRESS_DB_NAME=wordpress

MYSQL_DATABASE=wordpress
MYSQL_USER=wp_user
MYSQL_PASSWORD=wp_password
MYSQL_ROOT_PASSWORD=root_password
```

---

## 🧰 Option 1: Using Nix (Recommended for macOS/Linux)

If you use **Nix** with Flakes enabled:

```bash
nix develop
```

This will open a shell with Docker, Docker Compose, and (on macOS) Colima preinstalled.

Then start your environment:

```bash
docker-compose up -d
```

### Notes for macOS

If using Colima (for Docker runtime):

```bash
colima start --cpu 2 --memory 4 --disk 15
```

---

## 🐳 Option 2: Using Docker Directly

Make sure Docker is installed and running, then simply run:

```bash
docker-compose up -d
```

This will start two containers:

* `wordpress` (Apache + PHP)
* `db` (MariaDB 10.11)

After startup, WordPress should be available at:

```
http://localhost:8081
```

---

🗃️ Volumes

The `docker-compose.yml` mounts several volumes to persist content and override configuration files:

```yml
volumes:
  - ./wp-content:/var/www/html/wp-content
  - ./wp-config.php:/var/www/html/wp-config.php
  - ./uploads.ini:/usr/local/etc/php/conf.d/uploads.ini
```

### Explanation

`./wp-content:/var/www/html/wp-content`

> If you want to manually add plugins, themes, or upload files for testing.

`./wp-config.php:/var/www/html/wp-config.php`

>If you need to modify WordPress configuration directly (for testing custom settings).

`./uploads.ini:/usr/local/etc/php/conf.d/uploads.ini`

> If you want to adjust PHP upload or memory limits during testing.

---

## 🧹 Cleanup

To stop and remove containers, volumes, and networks:

```bash
docker-compose down -v
```

---

📜 License

MIT — free to use, modify, and distribute.
