# Development

The simplest way to build this image locally, it's to use Docker Compose.
To do so, you will need to create a `.env` file in cloned repo (it's git-ignored).

Example:

```conf
CP_DB_HOST=mariadb
CP_DB_NAME=classicpress
CP_DB_USER=myblog_user
CP_DB_PASSWORD=my_secret_password
DB_ROOT_PASSWORD=turbo_secret_password

```

Now, you simply run:

```sh
docker-compose -f docker-compose.dev.yaml up
```

The container will be accessible via http://localhost:8000 
