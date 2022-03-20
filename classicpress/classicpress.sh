#!/usr/bin/env bash

# ClassicPress Startup Script
TMP_WP_CONFIG=/tmp/wp-config.php

function load_secrets() {
  for secretFileName in $(env | cut -f1 -d= | grep "_FILE$"); do
    secretName="${secretFileName%_FILE}"
    echo "  Setting ${secretName}"
    export "${secretName}"="$(cat ${!secretFileName})"
  done
}

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
  random_key=`< /dev/urandom tr -dc "#%+0-;@-Z_a-z~" | head -c32; echo`
  printf -v "$1" "%s" "$random_key"
}

function store_env() {
  sed -i "s/$1/${!1}/g" "${TMP_WP_CONFIG}"
}


# Checking wp-config.php
if [ ! -f "${WP_CONFIG}" ]; then
    echo "Notice: File ${WP_CONFIG} not found - touching"
    touch "${WP_CONFIG}"
fi

if [ ! -w "${WP_CONFIG}" ]; then
    echo "Error: File ${WP_CONFIG} found, but not writable. Have you mounted the /data as a volume?"
    exit 1
fi

if [ -s "${WP_CONFIG}" ]; then
  echo "${WP_CONFIG} seems to be already configured. Not recreating."
else
  echo "Checking secrets ..."
  load_secrets

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
  cp "${WWW_DIR}/../wp-config.template.php" "${TMP_WP_CONFIG}"
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
  mv "${TMP_WP_CONFIG}" "${WP_CONFIG}"
fi


# Checking wp-content
if [ -d "${WP_CONTENT}" ]; then
  echo "${WP_CONTENT} found - ok"
else
  echo "Notice: ${WP_CONTENT} does not exist - restoring from the backup"
  cp -r "${BACKUP_WP_CONTENT}" "${WP_CONTENT}"
fi


# Chanigin ownership
echo "Changing ownership..."
sed -Ei "s/$APACHE_RUN_USER:x:[0-9]+:[0-9]+/$APACHE_RUN_USER:x:$APACHE_RUN_USER_ID:$APACHE_RUN_GROUP_ID/g" /etc/passwd
chown -R ${APACHE_RUN_USER}:${APACHE_RUN_GROUP} ${WWW_DIR} ${DATA_DIR}


# Starting apache
echo "Starting Apache in foreground ..."
# https://github.com/docker-library/php/blob/master/7.4/bullseye/apache/apache2-foreground
apache2-foreground
