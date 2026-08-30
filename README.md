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
├── wp-content/          # WordPress content folder (themes, plugins, uploads) — see Local Theme & Plugin Development below
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

This opens a shell with `docker` and `docker-compose` available. On macOS, `colima` is included in the Nix shell, start it manually if you use it as the Docker runtime:

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

> **Note:** If you see *"Error establishing a database connection"* right after startup, wait a few seconds and refresh — the database container may still be initializing. If the error persists, double-check that the credentials in `.env` match those configured in the MariaDB container.

---

## 🗃️ Volumes

The `docker-compose.yml` uses the following volumes:

```yml
volumes:
  - wp_content_data:/var/www/html/wp-content
  - ./uploads.ini:/usr/local/etc/php/conf.d/uploads.ini
```

### Explanation

`wp_content_data:/var/www/html/wp-content`

> A **named Docker volume** that persists `wp-content` (themes, plugins, uploads) across container restarts. Using a named volume (instead of a bind mount) ensures WordPress can correctly populate the folder from the image on first run — a bind mount with an empty local folder would override and wipe the container's content.

`./uploads.ini:/usr/local/etc/php/conf.d/uploads.ini`

> Lets you adjust PHP upload or memory limits during testing.

---

## 🛠 Local Theme & Plugin Development

By default, `wp-content` lives inside a named Docker volume (`wp_content_data`). To develop themes or plugins locally with live file sync, you need to switch to a **bind mount** instead.

### Step 1 — Extract `wp-content` from the container

The `./wp-content` folder in this repo is intentionally empty. A direct bind mount to an empty folder would break WordPress. Start the containers first to let Docker populate `wp-content` via the named volume, then copy it to your host:

```bash
docker-compose up -d
docker cp wp_apache:/var/www/html/wp-content ./
```

### Step 2 — Switch to a bind mount

Update `docker-compose.yml` to replace the named volume with a bind mount:

```yml
volumes:
  - ./wp-content:/var/www/html/wp-content   # bind mount for local dev
  - ./uploads.ini:/usr/local/etc/php/conf.d/uploads.ini
```

Also remove (or comment out) `wp_content_data` from the `volumes` section at the bottom of the file:

```yml
volumes:
  db_data:
  # wp_content_data:   # no longer needed
```

### Step 3 — Restart the containers

> ⚠️ **Do NOT use `docker-compose down -v` here.** The `-v` flag deletes all named volumes, including `db_data`, which would wipe your database. Use plain `down` instead.

```bash
docker-compose down       # stop containers, keep volumes intact
docker-compose up -d      # restart with the bind mount applied
```

Now `./wp-content` on your host is synced directly into the container — edit themes or plugins locally and changes reflect immediately.

---

## 🧹 Cleanup

To stop and remove containers, networks, and all volumes:

```bash
docker-compose down -v
```

> ⚠️ This will permanently delete all data including the database. Make sure you've already extracted `wp-content` to your host before running this.

---

## 🎬 Demo Video (YouTube)

### Install WordPress with Docker using Nix (on macOS with Colima)

[![Watch the video](https://img.youtube.com/vi/_ubAWrfAJb0/hqdefault.jpg)](https://youtu.be/_ubAWrfAJb0)

### Install WordPress with Docker (Directly on WSL2 / Ubuntu)

[![Watch the video](https://img.youtube.com/vi/8icS_YbJJjY/hqdefault.jpg)](https://youtu.be/8icS_YbJJjY)

---

## 📜 License

MIT — free to use, modify, and distribute.
