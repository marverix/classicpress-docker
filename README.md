# ClassicPress in Docker Image

Quote from [www.classicpress.net](https://www.classicpress.net/):

> ClassicPress is a community-led open source content management system and a fork of WordPress that preserves the TinyMCE classic editor as the default option.

## Changelog

[Open changelog](https://github.com/marverix/classicpress-docker/blob/master/CHANGELOG.md)

## Tags

### Convention

Tagging convention is: `CLASIC_PRESS_VERSION-rRELEASE`

`CLASIC_PRESS_VERSION` is ClassicPress version, `RELEASE` is Docker Image release number. Eg. `2.4.1-r1`.

## Basic Information

* The image is based on Alpine 3.22 and php 8.4
* Multi-plarform support: AMD64 (x86-64) and ARM64 (aarch64)
* Some code taken from [`TrafeX/docker-php-nginx:2.5.0`](https://github.com/TrafeX/docker-php-nginx) which I highly recommend! Unfortunatelly I coudln't use it (inherit) because Docker has no mechanism to "unexpose" port and remove health check
* Thanks to Alpine + Nginx + php-fpm, the image is using only around ~40MB of RAM
* Has enabled all required and recommended php extensions for WordPress
* Basic security hardening done
* Support for Docker Secrets via env variables with `_FILE` suffix

Note: Even with basic hardening done, it's highly recommended to not to expose a container directly to the outside world. Consider using a reverse proxy like [traefik](https://doc.traefik.io/traefik/) or [Nginx Proxy Manager](https://nginxproxymanager.com/).

### Current

https://hub.docker.com/r/marverix/classicpress/tags

## Usage

Good Docker practice is that one service/server == one docker container, this is why you will still need to run separate container
with a database (MySQL/MariaDB).

### Write Permission

This image deals with write access shared between host and the container by group `press` (and user) with ID _2048_. This is why your user running the container must be in this group.

If you are running Debian/Ubuntu-based run on your host machine:

```sh
sudo groupadd -g 2048 press
sudo usermod $(whoami) -aG press
```

Read more:

* [File Permissions: the painful side of Docker](https://blog.gougousis.net/file-permissions-the-painful-side-of-docker/)
* [Permission problems in bind mount in Docker Volume](https://techflare.blog/permission-problems-in-bind-mount-in-docker-volume/)
* [File permissions on Docker volumes](https://ikriv.com/blog/?p=4698)

### With Docker Compose

You will need to create own `docker-compose.yaml` file.
As a start point, you can use [`docker-compose.example.yaml`](https://github.com/marverix/classicpress-docker/blob/master/docker-compose.example.yaml) and [`myblog-env-example`](https://github.com/marverix/classicpress-docker/blob/master/myblog-env-example). Then simply run:

```sh
docker-compose -f docker-compose.example.yaml --env-file=myblog-env-example up
```

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
        --volume mariadb_data:/var/lib/mysql \
        --env MARIADB_DATABASE=myblog_db \
        --env MARIADB_USER=myblog_user \
        --env MARIADB_PASSWORD=my_secret_passowrd \
        --env MARIADB_ROOT_PASSWORD=my_turbo_secret_password \
        --restart=unless-stopped \
        mariadb:10.7.3
    ```

1. Create a volume where will be stored config and data.

    ```sh
    docker volume create myblog_data
    ```

1. Run

    ```sh
    docker run \
        --detach \
        --expose 80:80 \
        --name myblog \
        --volume myblog_data:/data \
        --env CP_DB_NAME=myblog_db \
        --env CP_DB_USER=myblog_user \
        --env CP_DB_PASSWORD=my_secret_passowrd \
        --env CP_DB_HOST=mariadb \
        --restart=unless-stopped \
        marverix/classicpress:latest
    ```
    
## Development

How-to is described in [a separate document](https://github.com/marverix/classicpress-docker/blob/master/DEVELOPMENT.md).
