#!/usr/bin/env bash

# ClassicPress Startup Script

function demand_env() {
  if [[ -z "${!1}" ]]; then
    echo "$1 is not set"
    exit 1
  fi
}

function support_env() {
  if [[ -z "${!1}" ]]; then
    printf -v "$1" "%s" "$2"
  fi
}

function random_env() {
  random_key=`openssl rand -hex 16`
  printf -v "$1" "%s" "$random_key"
}

function store_env() {
  sed -i "s/$1/${!1}/g" /tmp/wp-config.php
}


echo "Checking environment ..."
demand_env "CP_DB_NAME"
demand_env "CP_DB_USER"
demand_env "CP_DB_PASSWORD"
demand_env "CP_DB_HOST"
support_env "CP_DB_CHARSET" "utf8"
support_env "CP_DB_COLLATE" ""
support_env "CP_DB_TABLE_PREFIX" "cp_"

echo "Generating random strings ..."
random_env "CP_AUTH_KEY"
random_env "CP_SECURE_AUTH_KEY"
random_env "CP_LOGGED_IN_KEY"
random_env "CP_NONCE_KEY"
random_env "CP_AUTH_SALT"
random_env "CP_SECURE_AUTH_SALT"
random_env "CP_LOGGED_IN_SALT"
random_env "CP_NONCE_SALT"

echo "Preparing wp-config.php ..."
cp $WWW_DIR/wp-config.template.php /tmp/wp-config.php
store_env "CP_DB_NAME"
store_env "CP_DB_USER"
store_env "CP_DB_PASSWORD"
store_env "CP_DB_HOST"
store_env "CP_DB_CHARSET"
store_env "CP_DB_COLLATE"
store_env "CP_AUTH_KEY"
store_env "CP_SECURE_AUTH_KEY"
store_env "CP_LOGGED_IN_KEY"
store_env "CP_NONCE_KEY"
store_env "CP_AUTH_SALT"
store_env "CP_SECURE_AUTH_SALT"
store_env "CP_LOGGED_IN_SALT"
store_env "CP_NONCE_SALT"
store_env "CP_DB_TABLE_PREFIX"
mv /tmp/wp-config.php /data/wp-config.php

echo "Starting Apache in foreground ..."
# https://github.com/docker-library/php/blob/master/7.4/bullseye/apache/apache2-foreground
apache2-foreground
