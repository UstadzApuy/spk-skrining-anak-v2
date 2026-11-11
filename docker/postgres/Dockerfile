# Image PostgreSQL untuk SPK Skrining Anak.
# Berisi script init + file dump, sehingga tidak perlu bind mount
# (bind mount relatif tidak berfungsi di stack Git Portainer).
# Script init & restore hanya berjalan saat volume data masih kosong.
FROM postgres:18-alpine

COPY docker/postgres/init/ /docker-entrypoint-initdb.d/
RUN sed -i 's/\r$//' /docker-entrypoint-initdb.d/*.sh

# File dump yang di-restore saat pertama kali (relatif ke root repo)
ARG DB_DUMP_FILE=Database_UPTD_BLK-ABK.sql
COPY ${DB_DUMP_FILE} /dumps/dump
