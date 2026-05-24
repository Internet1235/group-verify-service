FROM node:20-slim AS frontend-builder

WORKDIR /app
COPY frontend/ /app/

RUN npm install
RUN npm run build


FROM php:8.4.21-cli-bookworm AS backend

ENV TZ=Asia/Shanghai

WORKDIR /app

# 安装 composer 所需的系统依赖
RUN apt-get update && apt-get install -y \
        unzip \
        libzip-dev \
        sqlite3 \
    && docker-php-ext-install zip \
    && rm -rf /var/lib/apt/lists/*

COPY backend/ /app/

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

COPY --from=frontend-builder /app/dist/ /app/public/static/verify/

RUN composer install --no-dev --optimize-autoloader


CMD ["php", "think", "run"]
