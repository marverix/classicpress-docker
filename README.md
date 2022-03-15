# ClassicPress in Docker Image

Quote from [www.classicpress.net](https://www.classicpress.net/):

> ClassicPress is a community-led open source content management system and a fork of WordPress that preserves the TinyMCE classic editor as the default option.

This repo contains only a Docker files required to build a Docker image containing ClassicPress.

## Usage

Good Docker practice is that one service/server == one docker container, this is why you will still need to run separate container
with a database (MySQL/MariaDB).

### With Docker Compose

TODO

### Manually

1. Create network

    ```sh
    docker network create --driver bridge classicpress_network
    ```

1. Set up MariaDB/MySQL:

    ```sh
    docker volume create mariadb_data
    docker run \
        --detach \
        --name mariadb \
        --volume mariadb_data:/var/lib/mysql/data \
        --env MARIADB_DATABASE=yourblogname_db \
        --env MARIADB_USER=yourblogname_user \
        --env MARIADB_PASSWORD=my_secret_passowrd \
        --env MARIADB_ROOT_PASSWORD=my_turbo_secret_password \
        --restart=unless-stopped \
        mariadb:10.7.3
    ```

1. Create a volume where will be stored config and data.

    ```sh
    docker volume create yourblogname_data
    ```

1. Run

    ```sh
    docker run \
        --detach \
        --expose 80:80 \
        --name yourblogname \
        --volume yourblogname_data:/data \
        --env CP_DB_NAME=yourblogname_db \
        --env CP_DB_USER=yourblogname_user \
        --env CP_DB_PASSWORD=my_secret_passowrd \
        --env CP_DB_HOST=mariadb \
        --restart=unless-stopped \
        marverix/classicpress:latest
    ```
    
## Build Locally

The simplest way to build this image locally, it's to use Docker Compose.
To do so, you will need to create a `.env` file in cloned repo (it's git-ignored).

Example:

```conf
CP_DB_HOST=mariadb
CP_DB_NAME=classicpress
CP_DB_USER=yourblogname_user
CP_DB_PASSWORD=my_secret_password
DB_ROOT_PASSWORD=turbo_secret_password

```

Now, you simply run:

```sh
docker-compose -f docker-compose.dev.yaml up
```

The container will be accessible via http://localhost:8000 
