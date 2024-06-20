#!/command/with-contenv sh

# exec gosu www-data php /var/www/artisan robots:generate
php "$APP_BASE_DIR/artisan" config:cache
php "$APP_BASE_DIR/artisan" migrate --force --isolated
