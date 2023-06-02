ARG PHP_VERSION=8.1.18
FROM php:${PHP_VERSION}-fpm

# php
ENV PHP_MEMORY_LIMIT=512M
ENV PHP_MAX_EXECUTION_TIME=60

# php-fpm
ENV PHP_LOG_LEVEL=notice
ENV PHP_PM=ondemand
ENV PHP_PM_max_children=10
ENV PHP_PM_process_idle_timeout=5s
ENV PHP_PM_max_requests=100
ENV PHP_PM_start_servers=1
ENV PHP_PM_min_spare_servers=1
ENV PHP_PM_max_spare_servers=16
ENV PHP_PM_max_spawn_rate=32
ENV PHP_PM_port=9000

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN chmod +x /usr/local/bin/install-php-extensions && \
    install-php-extensions @composer \
      bcmath \
      gd \
      intl \
      opcache \
      pdo_mysql \
      zip

RUN apt-get update \
  && apt-get -y upgrade \
  && apt-get -y install default-mysql-client jq rsync \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /code \
  && mkdir -p /public \
  && mkdir -p /private

COPY conf/php/custom.ini /usr/local/etc/php/conf.d/
COPY conf/php-fpm/www.conf /www.conf
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

RUN useradd -m -d /code -u 1080 php \
  && chown -R php /code /public /private \
  && chmod -R 755 /code /public /private \
  && rm /usr/bin/perl /usr/bin/perl5.32-x86_64-linux-gnu /usr/bin/perl5.32.1

USER php

WORKDIR /code/web

ENTRYPOINT ["/entrypoint.sh"]
CMD []
