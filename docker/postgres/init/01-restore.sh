#!/bin/bash
# Dijalankan otomatis oleh image postgres HANYA saat volume data masih kosong.
# Me-restore dump database SPK (SQL biasa atau format custom pgAdmin).
set -euo pipefail

DUMP=/dumps/dump

if [ -s "$DUMP" ]; then
    if [ "$(head -c 5 "$DUMP")" = "PGDMP" ]; then
        echo "[init] Restore dump (format custom) ke $POSTGRES_DB..."
        pg_restore --no-owner --no-privileges --exit-on-error \
            --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" "$DUMP"
    else
        echo "[init] Restore dump (format SQL) ke $POSTGRES_DB..."
        # Baris "OWNER TO ..." dilewati agar semua tabel dimiliki DB_USERNAME
        sed -e '/OWNER TO /d' "$DUMP" \
            | psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB"
    fi
else
    echo "[init] File dump tidak ada; tabel akan dibuat oleh migration."
fi

echo "[init] Selesai."
