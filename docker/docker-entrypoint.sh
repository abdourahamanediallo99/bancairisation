#!/bin/sh
set -e

echo "Waiting for database..."
while ! pg_isready -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USERNAME" > /dev/null 2>&1; do
    echo "Database not ready - sleeping"
    sleep 2
done

echo "Database ready!"

# Génère clés Passport si absentes (Secret Files les écraseront)
if [ ! -f storage/oauth-private.key ] || [ ! -f storage/oauth-public.key ]; then
    echo "Generating Passport keys..."
    php artisan passport:keys --force
fi

echo "Running migrations..."
php artisan migrate --force

echo "Optimizing Laravel..."
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan l5-swagger:generate

echo "Starting Supervisor..."
exec "$@"
