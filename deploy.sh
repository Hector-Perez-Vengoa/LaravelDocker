#!/usr/bin/env bash
# Script de despliegue "un solo comando" para entorno Linux limpio.
# Uso: bash deploy.sh   (o darle permisos y ./deploy.sh)
set -euo pipefail

PROJECT_NAME="crud-laravel"

echo "==> Comprobando dependencias (Docker + Docker Compose plugin)"
if ! command -v docker >/dev/null 2>&1; then
  echo "==> Instalando Docker (requiere sudo)"
  if [ -f /etc/debian_version ]; then
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg lsb-release
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$(. /etc/os-release; echo $ID) \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  else
    echo "Instala Docker manualmente para tu distro y vuelve a ejecutar." >&2
    exit 1
  fi
fi

echo "==> Asegurando que el daemon de Docker está activo"
if ! docker info >/dev/null 2>&1; then
  echo "Docker no está activo. Intenta iniciar el servicio (sudo systemctl start docker) y reintenta." >&2
  exit 1
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
