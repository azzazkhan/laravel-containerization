FROM serversideup/php:8.3-fpm-nginx

ENV PHP_OPCACHE_ENABLE 1
ENV APP_BASE_DIR /var/www
ENV COMPOSER_ALLOW_SUPERUSER 0
ENV NGINX_WEBROOT /var/www/public
ENV PHP_MAX_EXECUTION_TIME 30

WORKDIR /var/www

USER root

RUN curl -sL https://deb.nodesource.com/setup_20.x | bash -
RUN apt-get update && apt-get install -y vim supervisor nodejs iputils-ping
RUN npm i -g yarn

RUN install-php-extensions intl opcache pdo_mysql redis
RUN apt-get autoremove && apt-get autoclean

USER www-data

COPY --chown=www-data:www-data composer.json composer.lock ./
RUN composer install --no-interaction --no-autoloader --no-dev --no-scripts

COPY --chown=www-data:www-data package.json yarn.lock ./
RUN yarn install --non-interactive

USER root

COPY docker/nginx/nginx.conf.template /etc/nginx/nginx.conf.template
COPY docker/nginx/fastcgi_params /etc/nginx/fastcgi_params
COPY docker/nginx/healthcheck.conf /etc/nginx/healthcheck.conf
COPY docker/nginx/conf.d/ /etc/nginx/conf.d/
COPY docker/nginx/site-opts.d/ /etc/nginx/site-opts.d/

COPY --chown=www-data:www-data . .
RUN chmod -R 0755 bootstrap/cache storage

USER www-data

RUN composer dump-autoload
RUN yarn build
RUN touch database/database.sqlite
