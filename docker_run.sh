#!/bin/bash
set -e

env >> /.env
php artisan clear-compiled
php artisan config:clear
php-fpm -D
nginx -g "daemon off;"

