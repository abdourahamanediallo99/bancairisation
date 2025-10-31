# docker/Dockerfile
FROM php:8.3-fpm-alpine AS base

# === 1. Dépendances système ===
RUN apk add --no-cache \
    git curl zip unzip supervisor nginx \
    libpng-dev libzip-dev postgresql-dev \
    && docker-php-ext-install pdo_pgsql mbstring exif pcntl bcmath gd zip

# === 2. Composer (multi-stage) ===
FROM composer:2.7 AS composer
WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader --no-interaction --prefer-dist --no-scripts

# === 3. Image finale ===
FROM base
WORKDIR /var/www

# === Copie code + vendor ===
COPY --from=composer /app/vendor ./vendor
COPY . .

# === Permissions ===
RUN chown -R www-data:www-data /var/www \
    && chmod -R 755 storage bootstrap/cache \
    && mkdir -p /var/log/nginx /var/log/supervisor \
    && chown -R www-data:www-data /var/log/nginx /var/log/supervisor

# === Supervisor + Nginx ===
COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY docker/nginx.conf /etc/nginx/sites-available/default
RUN ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/

# === Entrypoint (migrations + keys) ===
COPY docker/docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# === Expose ===
EXPOSE 80

# === CMD ===
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
