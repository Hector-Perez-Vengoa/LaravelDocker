#!/usr/bin/env bash
set -euo pipefail

echo "[entrypoint] Iniciando contenedor Laravel"

if [ ! -f .env ]; then
  echo "[entrypoint] .env no existe, copiando .env.example"
  cp .env.example .env
fi

# Forzar configuración MySQL si está levantándose con Docker
grep -q '^DB_CONNECTION=' .env && sed -i 's/^DB_CONNECTION=.*/DB_CONNECTION=mysql/' .env || echo 'DB_CONNECTION=mysql' >> .env
grep -q '^DB_HOST=' .env && sed -i 's/^DB_HOST=.*/DB_HOST=db/' .env || echo 'DB_HOST=db' >> .env
grep -q '^DB_PORT=' .env && sed -i 's/^DB_PORT=.*/DB_PORT=3306/' .env || echo 'DB_PORT=3306' >> .env
grep -q '^DB_DATABASE=' .env && sed -i 's/^DB_DATABASE=.*/DB_DATABASE=laravel/' .env || echo 'DB_DATABASE=laravel' >> .env
grep -q '^DB_USERNAME=' .env && sed -i 's/^DB_USERNAME=.*/DB_USERNAME=laravel/' .env || echo 'DB_USERNAME=laravel' >> .env
grep -q '^DB_PASSWORD=' .env && sed -i 's/^DB_PASSWORD=.*/DB_PASSWORD=secret/' .env || echo 'DB_PASSWORD=secret' >> .env

if ! grep -q '^APP_KEY=' .env || grep -q '^APP_KEY=$' .env; then
  echo "[entrypoint] Generando APP_KEY"
  php artisan key:generate --force || true
fi

echo "[entrypoint] Ejecutando composer install si es necesario"
if [ ! -d vendor ]; then
  composer install --prefer-dist --no-interaction --no-progress
fi

echo "[entrypoint] Esperando a la base de datos..."
ATTEMPTS=0
until php -r "new PDO('mysql:host=' . getenv('DB_HOST') . ';port=' . getenv('DB_PORT'), getenv('DB_USERNAME'), getenv('DB_PASSWORD'));" 2>/dev/null; do
  ATTEMPTS=$((ATTEMPTS+1))
  if [ $ATTEMPTS -gt 30 ]; then
    echo "[entrypoint] No se pudo conectar a la base de datos" >&2
    exit 1
  fi
  sleep 2
done

echo "[entrypoint] Base de datos disponible, ejecutando migraciones"
php artisan migrate --force || true

echo "[entrypoint] Iniciando servidor de desarrollo"
exec "$@"
