#!/usr/bin/env bash
set -e

# Skrip Checkpoint & Reset Lingkungan Pengujian SPK Skrining Anak (SDIDTK)
# UPTD Balai Layanan Kesehatan Anak Berkebutuhan Khusus Kota Balikpapan

if command -v docker >/dev/null 2>&1 && docker ps --format '{{.Names}}' | grep -q 'spk-skrining-anak-v3-app'; then
    docker exec -e HOME=/tmp spk-skrining-anak-v3-app php artisan test:reset
elif command -v php >/dev/null 2>&1; then
    php artisan test:reset
else
    echo "Error: PHP atau Docker container 'spk-skrining-anak-v3-app' tidak ditemukan."
    exit 1
fi

