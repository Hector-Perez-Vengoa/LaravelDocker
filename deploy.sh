#!/usr/bin/env bash
# Script de despliegue "un solo comando" para entorno Linux limpio.
# Uso: bash deploy.sh   (o darle permisos y ./deploy.sh)
set -euo pipefail

MODE="docker" # por defecto
for arg in "$@"; do
  case "$arg" in
    --local)
      MODE="local";
      shift;;
  esac
done

local_mode() {
  echo "==> Modo local (sin daemon Docker) habilitado"
  command -v php >/dev/null 2>&1 || { echo "[ERROR] PHP no está instalado en este contenedor." >&2; exit 1; }
  command -v composer >/dev/null 2>&1 || { echo "[ERROR] Composer no está instalado en este contenedor." >&2; exit 1; }
  if [ ! -f .env ]; then
    cp .env.example .env
  fi
  # Forzar SQLite
  sed -i 's/^DB_CONNECTION=.*/DB_CONNECTION=sqlite/' .env || true
  # Eliminar líneas antiguas de host/usuario/password para evitar confusión
  sed -i '/^DB_HOST=/d;/^DB_PORT=/d;/^DB_DATABASE=/d;/^DB_USERNAME=/d;/^DB_PASSWORD=/d' .env || true
  mkdir -p database
  if [ ! -f database/database.sqlite ]; then
    touch database/database.sqlite
  fi
  if ! grep -q '^APP_KEY=' .env || grep -q '^APP_KEY=$' .env; then
    php artisan key:generate --force || true
  fi
  echo "==> Instalando dependencias Composer"
  composer install --no-interaction --prefer-dist
  echo "==> Ejecutando migraciones"
  php artisan migrate --force
  echo "==> Iniciando servidor (puerto 8000)"
  exec php artisan serve --host=0.0.0.0 --port=8000
}

if [ "$MODE" = "local" ]; then
  local_mode
fi

PROJECT_NAME="crud-laravel"

echo "==> Comprobando dependencias (Docker + Docker Compose plugin)"

# Determinar comando sudo (o vacío si somos root o no existe sudo)
if command -v sudo >/dev/null 2>&1; then
  SUDO="sudo"
else
  if [ "$(id -u)" = "0" ]; then
    SUDO="" # somos root, no necesitamos sudo
  else
    echo "[WARN] 'sudo' no está instalado y no eres root. Instálalo o ejecuta el script como root." >&2
    exit 1
  fi
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "==> Docker no encontrado. Instalando (Debian/Ubuntu detectado: $( [ -f /etc/debian_version ] && echo si || echo no ))"
  if [ -f /etc/debian_version ]; then
    $SUDO apt-get update
    $SUDO apt-get install -y ca-certificates curl gnupg lsb-release
    $SUDO install -m 0755 -d /etc/apt/keyrings
    if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
      curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | $SUDO gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    fi
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$(. /etc/os-release; echo $ID) $(lsb_release -cs) stable" | $SUDO tee /etc/apt/sources.list.d/docker.list >/dev/null
    $SUDO apt-get update
    $SUDO apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  else
    echo "Instala Docker manualmente para tu distribución y vuelve a ejecutar." >&2
    exit 1
  fi
fi

echo "==> Asegurando que el daemon de Docker está activo"
if ! docker info >/dev/null 2>&1; then
  # Detectar si estamos dentro de contenedor o sin systemd
  IN_CONTAINER=0
  if grep -qiE 'docker|podman' /proc/1/cgroup 2>/dev/null || [ -f /.dockerenv ] || [ -f /run/.containerenv ]; then
    IN_CONTAINER=1
  fi

  if command -v systemctl >/dev/null 2>&1; then
    $SUDO systemctl start docker 2>/dev/null || true
  elif command -v service >/dev/null 2>&1; then
    $SUDO service docker start 2>/dev/null || true
  fi
  sleep 2
  if ! docker info >/dev/null 2>&1; then
  echo "[ERROR] Docker daemon no está corriendo." >&2
    if [ $IN_CONTAINER -eq 1 ]; then
      cat >&2 <<'EOF'
Parece que estás dentro de un contenedor o entorno sin systemd.
No puedes iniciar el daemon Docker aquí dentro (docker-dentro-de-docker sin configuración especial).
Opciones:
  1. Ejecuta este script en la máquina host donde sí corre Docker (recomendado).
  2. Usa WSL2 con Docker Desktop habilitado (activa integration) y ejecuta allí.
  3. Instala Docker rootless para usuario (experimental):
       apt-get install -y dbus-user-session uidmap slirp4netns fuse-overlayfs
       curl -fsSL https://get.docker.com/rootless | sh
       export PATH=$HOME/bin:$PATH
       export DOCKER_HOST=unix:///run/user/$(id -u)/docker.sock
       dockerd-rootless-setuptool.sh install
       (Reabre la shell y reintenta)
  4. Alternativa sin Docker: instala PHP, Composer, MySQL y corre artisan serve local.
   5. Usa el fallback SQLite inmediato: ./deploy.sh --local
EOF
    else
      cat >&2 <<'EOF'
Sugerencias para iniciar Docker:
  systemctl enable --now docker    # (si hay systemd)
  ó service docker start

Si estás en WSL2: edita /etc/wsl.conf con:
  [boot]\nsystemd=true
Luego reinicia: wsl --shutdown (desde Windows) y reintenta.
EOF
    fi
    if [ $IN_CONTAINER -eq 1 ]; then
      echo "Puedes intentar ahora: ./deploy.sh --local (modo SQLite)" >&2
    fi
    exit 1
  fi
fi

echo "==> Creando archivo .env si no existe"
if [ ! -f .env ]; then
  cp .env.example .env
fi

echo "==> Levantando stack (build + up)"
docker compose up -d --build

echo "==> Esperando a que la app responda (http://localhost:8000)"
ATTEMPTS=0
until curl -fsS http://localhost:8000 >/dev/null 2>&1; do
  ATTEMPTS=$((ATTEMPTS+1))
  if [ $ATTEMPTS -gt 60 ]; then
    echo "Timeout esperando la aplicación" >&2
    docker compose logs app | tail -n 100 || true
    exit 1
  fi
  sleep 2
done

echo "============================================================"
echo "Aplicación desplegada correctamente"
echo "URL: http://localhost:8000"
echo "Contenedores activos:"
docker compose ps
echo "Logs rápidos (últimas 30 líneas):"
docker compose logs --tail=30 app
echo "============================================================"
