#!/bin/sh
# Entrypoint container backend SPK Skrining Anak.
# Dijalankan setiap container start, sebelum php-fpm.
set -e
cd /var/www/html

if [ -z "$APP_KEY" ]; then
    echo "[entrypoint] APP_KEY belum diisi. Buat dengan: php artisan key:generate --show" >&2
    exit 1
fi

# Volume storage bisa kosong saat pertama kali dipasang
mkdir -p storage/app/public storage/framework/cache/data storage/framework/sessions \
         storage/framework/views storage/logs

if [ "${RUN_MIGRATIONS:-true}" = "true" ]; then
    echo "[entrypoint] Menjalankan migration..."
    php artisan migrate --force
fi

echo "[entrypoint] Cache config, route, view..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Sinkron pasien & akun wali dari SILKABK. Gagal sinkron tidak menghentikan container
# (SPK tetap jalan; sinkron juga terjadi otomatis saat login dari SILKABK).
if [ "${SILKABK_SYNC_ON_START:-true}" = "true" ]; then
    echo "[entrypoint] Sinkron data dari SILKABK..."
    php artisan silkabk:sync || echo "[entrypoint] PERINGATAN: sinkron SILKABK gagal, lanjut start." >&2
fi

exec "$@"
