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
├── uploads.ini          # PHP overrides (upload and execution limits)
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

### 2. Start WordPress Containers

#### Option 1: Using Nix

If you use **Nix** with Flakes enabled (recommended if you already use Nix):

```bash
nix develop
```

This opens a shell with docker and docker-compose available. On macOS, colima is included in the Nix shell, start it manually if you use it as the Docker runtime:

```
colima start --cpu 2 --memory 4 --disk 15
```

Then start your environment:

```bash
docker-compose up -d
```

After startup, access WordPress at:

```
http://localhost:8081
```

---

#### Option 2: Using Docker Directly

Make sure Docker is installed and running, then simply run:

```bash
docker-compose up -d
```

This will start two containers:

* `wordpress` (Apache + PHP)
* `db` (MariaDB 10.11)

After startup, access WordPress at:

```
http://localhost:8081
```

Notes:

If after running `docker-compose up -d` you see the message *“Error establishing a database connection”* when accessing `http://localhost:8081`, this is usually caused by a delay in the database container initialization. Try waiting a few seconds and then accessing the page again. If the problem persists, make sure the database credentials in the `.env` file match those configured in the MariaDB container.

---

## 🗃️ Volumes

The `docker-compose.yml` mounts several volumes to persist content and override configuration files:

```yml
volumes:
  - ./wp-content:/var/www/html/wp-content
  - ./uploads.ini:/usr/local/etc/php/conf.d/uploads.ini
```

### Explanation

`./wp-content:/var/www/html/wp-content`

> If you want to manually add plugins, themes, or upload files for testing.

`./uploads.ini:/usr/local/etc/php/conf.d/uploads.ini`

> If you want to adjust PHP upload or memory limits during testing.

---

## 🧹 Cleanup

To stop and remove containers, volumes, and networks:

```bash
docker-compose down -v
```

---

## 🎬 Demo Video (YouTube)

### Install WordPress with Docker using Nix (on macOS with Colima)

[![Watch the video](https://img.youtube.com/vi/_ubAWrfAJb0/hqdefault.jpg)](https://youtu.be/_ubAWrfAJb0)

### Install WordPress with Docker (Directly on WSL2 / Ubuntu)

[![Watch the video](https://img.youtube.com/vi/8icS_YbJJjY/hqdefault.jpg)](https://youtu.be/8icS_YbJJjY)

---

## 📜 License

MIT — free to use, modify, and distribute.
