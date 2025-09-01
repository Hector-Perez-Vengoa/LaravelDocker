#!/usr/bin/env bash
set -euo pipefail

echo "[start.sh] Preparando entorno Laravel..."

if [ ! -f .env ]; then
  if [ -f .env.example ]; then
    echo "[start.sh] Copiando .env.example -> .env"; cp .env.example .env || true
  else
    echo "[start.sh] WARNING: .env.example no existe. Creando .env mínimo";
    cat > .env <<EOF
APP_KEY=
APP_ENV=local
APP_DEBUG=true
APP_URL=http://localhost:8000
LOG_CHANNEL=stack
DB_CONNECTION=mysql
DB_HOST=${DB_HOST:-db}
DB_PORT=${DB_PORT:-3306}
DB_DATABASE=${DB_DATABASE:-laravel}
DB_USERNAME=${DB_USERNAME:-laravel}
DB_PASSWORD=${DB_PASSWORD:-laravel}
EOF
  fi
fi

# Asegurar dependencias (opcional si vendor ya está montado)
if [ ! -d vendor ]; then
  echo "[start.sh] Instalando dependencias composer (vendor faltante)";
  composer install --no-interaction --prefer-dist --no-progress || true
fi

php artisan config:clear || true
php artisan key:generate --force || true
echo "[start.sh] Ejecutando migraciones";
if ! php artisan migrate --force; then
  echo "[start.sh] Primer intento falló. Reintentando en 8s"; sleep 8; php artisan migrate --force || echo "[start.sh] Migraciones siguen fallando (continuando)";
fi

echo "[start.sh] Iniciando servidor en 0.0.0.0:8000";
exec php artisan serve --host=0.0.0.0 --port=8000
