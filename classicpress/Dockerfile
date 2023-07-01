FROM php:8.1-apache-bullseye

# Version of ClassicPress
ARG version=1.5.3
ARG corerules_version=3.3.4
ARG www_dir=/var/www/html

ARG WORKDIR_BUILD=/tmp/build
ARG WORKDIR_FILES=${WORKDIR_BUILD}/files
ARG WORKDIR_DOWNLOADS=${WORKDIR_BUILD}/downloads

ENV WWW_DIR=${www_dir}
ENV DATA_DIR=/data
ENV WP_CONFIG=${DATA_DIR}/wp-config.php
ENV WP_CONTENT=${DATA_DIR}/wp-content
ENV BACKUP_WP_CONTENT="${WWW_DIR}/../wp-content-backup"

ENV APACHE_RUN_USER=apache
ENV APACHE_RUN_GROUP=www-data

ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8

COPY ./ ${WORKDIR_FILES}/

# Install packages
RUN apt-get update \
 && apt-get install -y \
    apt-transport-https lsb-release ca-certificates wget gnupg2 \
 && wget -qO - https://modsecurity.digitalwave.hu/archive.key | apt-key add - \
 && sh -c 'echo "deb http://modsecurity.digitalwave.hu/debian/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/dwmodsec.list' \
 && sh -c 'echo "deb http://modsecurity.digitalwave.hu/debian/ $(lsb_release -sc)-backports main" >> /etc/apt/sources.list.d/dwmodsec.list' \
 && apt-get update \
 && apt-get install -y \
    libapache2-mod-security2 libmodsecurity3 \
    zlib1g-dev libpng16-16 libpng-dev libzip4 libzip-dev locales \
# Ensure UTF-8
 && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
 && locale-gen \
# Change working directory
 && mkdir -p ${WORKDIR_DOWNLOADS} \
 && cd ${WORKDIR_DOWNLOADS} \
# Download ClassicPress
 && wget -qO classicpress.tar.gz https://github.com/ClassicPress/ClassicPress-release/archive/refs/tags/${version}.tar.gz \
# Download corerules
 && wget -qO corerules.tar.gz https://github.com/coreruleset/coreruleset/archive/refs/tags/v${corerules_version}.tar.gz \
# Clean www_dir
 && rm -rf ${www_dir}/* \
# Unpack ClassicPress to www_dir
 && tar -xf classicpress.tar.gz -C ${www_dir} --strip-components=1 \
# Create /data
 && mkdir ${DATA_DIR} \
 && cd ${DATA_DIR} \
# Move wp-content to /data
 && mv ${www_dir}/wp-content ${WP_CONTENT} \
 && ln -s ${WP_CONTENT} ${www_dir}/wp-content \
 && cp -r ${WP_CONTENT} ${BACKUP_WP_CONTENT} \
# Init wp-config.php
 && touch ${WP_CONFIG} \
 && ln -s ${WP_CONFIG} ${www_dir}/wp-config.php \
# Copy wp-config.template.php
 && cp ${WORKDIR_FILES}/wp-config.template.php ${www_dir}/../wp-config.template.php \
# Copy php.ini
 && cp ${WORKDIR_FILES}/php.ini "${PHP_INI_DIR}/php.ini" \
# Install missing php extensions
 && EXTRA_CFLAGS="-I/usr/src/php" docker-php-ext-install \
    exif gd mysqli zip \
# Enable apache mod-rewrite
 && a2enmod rewrite \
# Enable apache mod-headers
 && a2enmod headers \
# Enable mod-security2
 && a2enmod security2 \
 && cp /etc/modsecurity/modsecurity.conf-recommended /etc/modsecurity/modsecurity.conf \
 && sed -Ei "s/Sec([A-Z][a-z]+)Engine .+/Sec\1Engine On/g" /etc/modsecurity/modsecurity.conf \
 && cp ${WORKDIR_FILES}/security2.conf /etc/apache2/mods-available/security2.conf \
# Setup mod-security2
 && cd /usr/share/modsecurity-crs \
 && rm -rf ./* \
 && tar -xf ${WORKDIR_DOWNLOADS}/corerules.tar.gz -C ./ --strip-components=1 \
 && mv crs-setup.conf.example crs-setup.conf \
 && mv ./rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf.example ./rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf \
# Copy default site conf
 && cp ${WORKDIR_FILES}/000-default.conf /etc/apache2/sites-available/000-default.conf \
# Copy security conf
 && cp ${WORKDIR_FILES}/security.conf /etc/apache2/conf-available/security.conf \
# Copy htaccess
 && cp ${WORKDIR_FILES}/htaccess ${DATA_DIR}/.htaccess \
 && ln -s ${DATA_DIR}/.htaccess ${www_dir}/.htaccess \
# Copy startup script
 && cp ${WORKDIR_FILES}/classicpress.sh /opt/classicpress.sh \
# Create user
 && useradd -rMUG daemon,www-data apache \
# Clean
 && apt-get purge -y --auto-remove \
    wget zlib1g-dev \
 && apt-get autoclean \
 && rm -r /var/lib/apt/lists/* \
 && rm -rf /tmp/*

# Set back www_dir as workdir
WORKDIR ${www_dir}

# Expose port 80
EXPOSE 80

# It's important to NOT change user with USER. We want to have root permissions
# in startup script, so we can dynamcally change UID/GID and ownership.

# Set startup command
CMD [ "/opt/classicpress.sh" ]
