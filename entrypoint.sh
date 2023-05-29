#!/usr/bin/env bash

set -euo pipefail

printf "Starting php-fpm\n"

exec php-fpm --fpm-config /www.conf
