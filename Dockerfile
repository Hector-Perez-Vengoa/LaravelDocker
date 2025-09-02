FROM php:8.2-cli

# Instala dependencias del sistema y extensiones PHP necesarias
RUN apt-get update \
    && apt-get install -y --no-install-recommends git unzip libzip-dev libpq-dev libonig-dev libxml2-dev default-mysql-client \
    && docker-php-ext-install pdo pdo_mysql \
    && rm -rf /var/lib/apt/lists/*

# Instala Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Copia solo archivos de dependencias primero para aprovechar cache
COPY composer.json composer.lock ./
RUN composer install --no-scripts --no-dev --prefer-dist --no-interaction --no-progress || true

# Copia el resto del código
COPY . .

# Entrypoint
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8000

ENTRYPOINT ["/entrypoint.sh"]
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
