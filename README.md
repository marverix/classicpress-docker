# ClassicPress in Docker Image

Quote from [www.classicpress.net](https://www.classicpress.net/):

> ClassicPress is a community-led open source content management system and a fork of WordPress that preserves the TinyMCE classic editor as the default option.

## Tags

### Current

* `1.3`, `1.3.1`, `cp1.3`, `cp1.3.1`, `cp1.3.1-rev1`, `latest`
### Convention

Tagging convention is: `cpXXX-revYYY`

`XXX` is ClassicPress version. `YYY` is Docker Image revision number.
## Basic Information

* The image is based on [`php:7.4-apache-bullseye`](https://hub.docker.com/_/php?tab=tags&name=7.4-apache-bullseye)
* Has enabled all required and recommended php extensions for WordPress
* Has installed [`apache2-mod-security2`](https://github.com/SpiderLabs/ModSecurity) with [enabled OWASP CSR](https://owasp.org/www-project-modsecurity-core-rule-set/)
* Support for Docker Secrets via env variables with `_FILE` suffix

Note: Even with basic hardening done, it's highly recommended to not to expose a container directly to the outside world. Consider using a reverse proxy like [traefik](https://doc.traefik.io/traefik/) or [Nginx Proxy Manager](https://nginxproxymanager.com/).

## Usage

Good Docker practice is that one service/server == one docker container, this is why you will still need to run separate container
with a database (MySQL/MariaDB).

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
        --volume mariadb_data:/var/lib/mysql/data \
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
