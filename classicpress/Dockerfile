FROM alpine:3.20

LABEL Maintainer="Marek Sierociński"
LABEL Description="ClassicPress image based on trafex/php-nginx"

# Version of ClassicPress
ARG version=2.2.0
# ARG corerules_version=3.3.4
ARG www_dir=/var/www/html

ARG WORKDIR_BUILD=/tmp/build
ARG WORKDIR_FILES=${WORKDIR_BUILD}/files
ARG WORKDIR_DOWNLOADS=${WORKDIR_BUILD}/downloads

ENV WWW_DIR=${www_dir}
ENV DATA_DIR=/data
ENV WP_CONFIG=${DATA_DIR}/wp-config.php
ENV WP_CONTENT=${DATA_DIR}/wp-content
ENV PRESS_USER=press
ENV PRESS_HOME=/home/${PRESS_USER}
ENV BACKUP_WP_CONTENT="${PRESS_HOME}/wp-content-backup"

WORKDIR /var/www/html

# Update packages index
RUN apk update \
 # Install packages
 && apk add --no-cache \
  bash \
  curl \
  nginx \
  php82 \
  php82-ctype \
  php82-curl \
  php82-dom \
  php82-fpm \
  php82-gd \
  php82-intl \
  php82-mbstring \
  php82-mysqli \
  php82-opcache \
  php82-openssl \
  php82-phar \
  php82-session \
  php82-xml \
  php82-xmlreader \
  php82-zlib \
  supervisor

COPY ./ ${WORKDIR_FILES}/

# Prepare users
RUN adduser -D -u 2048 press \
 && addgroup press press \
 && addgroup press nginx

# Configure services
RUN cp ${WORKDIR_FILES}/conf/php.ini /etc/php82/conf.d/custom.ini \
 && cp ${WORKDIR_FILES}/conf/fpm-pool.conf /etc/php82/php-fpm.d/www.conf \
 && cp ${WORKDIR_FILES}/conf/nginx.conf /etc/nginx/nginx.conf \
 && cp ${WORKDIR_FILES}/conf/supervisord.conf /etc/supervisord.conf \
&& rm -rf ${www_dir}/*

# Install ClassicPress
RUN mkdir -p ${WORKDIR_DOWNLOADS} && cd ${WORKDIR_DOWNLOADS} \
 && wget -qO classicpress.tar.gz https://github.com/ClassicPress/ClassicPress-release/archive/refs/tags/${version}.tar.gz \
 && tar -xf classicpress.tar.gz -C ${www_dir} --strip-components=1

# Setup
# Create /data
RUN mkdir ${DATA_DIR} && cd ${DATA_DIR} \
# Move wp-content to /data
 && mv ${www_dir}/wp-content ${WP_CONTENT} \
 && ln -s ${WP_CONTENT} ${www_dir}/wp-content \
 && cp -r ${WP_CONTENT} ${BACKUP_WP_CONTENT} \
# Init wp-config.php
 && touch ${WP_CONFIG} \
 && ln -s ${WP_CONFIG} ${www_dir}/wp-config.php \
# Copy wp-config.template.php
 && cp ${WORKDIR_FILES}/wp-config.template.php ${PRESS_HOME}/wp-config.template.php \
# Copy startup script
 && cp ${WORKDIR_FILES}/classicpress.sh ${PRESS_HOME}/classicpress.sh \
# Privilages
 && cp ${WORKDIR_FILES}/ch/chmod /bin/schmod \
 && cp ${WORKDIR_FILES}/ch/chgrp /bin/schgrp \
 && chmod +s /bin/schmod /bin/schgrp \
 && chmod +x ${PRESS_HOME}/classicpress.sh \
 && chown -R ${PRESS_USER}:${PRESS_USER} /data ${www_dir} \
 && chmod -R 777 /run /var/log \
# Clean
 && rm -rf /tmp/*

USER press

EXPOSE 80

HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1/fpm-ping

# Set startup command
CMD [ "/home/press/classicpress.sh" ]
