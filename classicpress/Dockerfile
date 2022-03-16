FROM php:7.4-apache-bullseye

# Version of ClassicPress
ARG version=1.3.1
ARG corerules_version=3.3.2
ARG www_dir=/var/www/html
ENV WWW_DIR=${www_dir}

# Install packages
RUN apt-get update \
 && apt-get install -y \
    locales wget \
    libapache2-mod-security2 \
    zlib1g-dev libpng16-16 libpng-dev libzip4 libzip-dev

# Ensure UTF-8
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
 && locale-gen

ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8

# Change workdir to /tmp
WORKDIR /tmp

# Download ClassicPress
RUN wget -qO classicpress.tar.gz https://github.com/ClassicPress/ClassicPress-release/archive/refs/tags/${version}.tar.gz

# Download corerules
RUN wget -qO corerules.tar.gz https://github.com/coreruleset/coreruleset/archive/refs/tags/v${corerules_version}.tar.gz

# Clean www_dir
RUN rm -rf ${www_dir}/*

# Unpack ClassicPress to www_dir
RUN tar -xf classicpress.tar.gz -C ${www_dir} --strip-components=1

# Create /data
RUN mkdir /data
WORKDIR /data

# Move themes to /data
RUN mv ${www_dir}/wp-content/themes ./themes \
 && ln -s /data/themes ${www_dir}/wp-content/themes

# Move plugins to /data
RUN mv ${www_dir}/wp-content/plugins ./plugins \
 && ln -s /data/plugins ${www_dir}/wp-content/plugins

# Prepare uploads dir
RUN mkdir uploads \
 && ln -s /data/uploads ${www_dir}/wp-content/uploads

# Init wp-config.php
RUN touch wp-config.php \
 && ln -s /data/wp-config.php ${www_dir}/wp-config.php

# Copy wp-config.template.php
COPY wp-config.template.php ${www_dir}/wp-config.template.php

# Copy php.ini
COPY php.ini "${PHP_INI_DIR}/php.ini"

# Install missing php extensions
RUN EXTRA_CFLAGS="-I/usr/src/php" docker-php-ext-install \
    exif gd mysqli zip

# Enable apache mod-rewrite
RUN a2enmod rewrite

# Enable apache mod-headers
RUN a2enmod headers

# Enable mod-security2
RUN a2enmod security2
RUN cp /etc/modsecurity/modsecurity.conf-recommended /etc/modsecurity/modsecurity.conf \
 && sed -Ei "s/Sec([A-Z][a-z]+)Engine .+/Sec\1Engine On/g" /etc/modsecurity/modsecurity.conf
COPY security2.conf /etc/apache2/mods-available/security2.conf

# Setup mod-security2
WORKDIR /usr/share/modsecurity-crs
RUN rm -rf ./* \
 && tar -xf /tmp/corerules.tar.gz -C ./ --strip-components=1 \
 && mv crs-setup.conf.example crs-setup.conf \
 && mv ./rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf.example ./rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf

# Copy default site conf
COPY 000-default.conf /etc/apache2/sites-available/000-default.conf

# Copy security conf
COPY security.conf /etc/apache2/conf-available/security.conf

# Copy htaccess
COPY htaccess /data/.htaccess
RUN ln -s /data/.htaccess ${www_dir}/.htaccess

# Clean
RUN apt-get purge -y --auto-remove \
    wget zlib1g-dev \
 && apt-get autoclean \
 && rm -r /var/lib/apt/lists/* \
 && rm -rf /tmp/*

# Set back www_dir as workdir
WORKDIR ${www_dir}

# Expose port 80
EXPOSE 80

# Set startup command
COPY classicpress.sh /opt/classicpress.sh
CMD [ "/opt/classicpress.sh" ]
