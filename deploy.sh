#!/usr/bin/env bash
# Script de despliegue "un solo comando" para entorno Linux limpio.
# Uso: bash deploy.sh   (o darle permisos y ./deploy.sh)
set -euo pipefail

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
  # Intentar iniciar docker con systemctl o service
  if command -v systemctl >/dev/null 2>&1; then
    $SUDO systemctl start docker || true
  elif command -v service >/dev/null 2>&1; then
    $SUDO service docker start || true
  fi
  sleep 2
  if ! docker info >/dev/null 2>&1; then
    echo "Docker no está activo. Inícialo manualmente y reintenta." >&2
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
