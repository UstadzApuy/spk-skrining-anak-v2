# Deploy SPK Skrining Anak (terhubung ke SILKABK)

Panduan lengkap kedua sistem ada di repo SILKABK: `DEPLOY.md`
(`bucks23/SILKABK`, branch `testing-deploy`). Ringkasnya:

- `docker-compose.yml` di root = **produksi** (db + backend PHP-FPM + frontend Nginx),
  semua image di-build dari repo, tanpa bind mount dan tanpa file `.env` wajib.
- `compose.dev.yaml` = pengembangan (artisan serve): `docker compose -f compose.dev.yaml up -d`
- Port host: frontend **8810** (HTTP, tujuan reverse proxy), backend **8809** (FastCGI).
- Tersambung ke SILKABK lewat jaringan Docker **`uptd-network`** yang dibuat stack SILKABK.
  **Deploy SILKABK lebih dulu.**

## Variabel (Portainer: Environment variables, atau file `.env`)

```env
APP_KEY=base64:...                # docker run --rm php:8.2-cli php -r "echo 'base64:'.base64_encode(random_bytes(32)).PHP_EOL;"
APP_URL=https://spk.domain.id
DB_PASSWORD=...
SILKABK_URL=https://silkabk.domain.id
SILKABK_SSO_SECRET=...            # = SPK_SKRINING_SSO_SECRET di stack SILKABK
SILKABK_DB_PASSWORD=...           # = SPK_READER_PASSWORD di stack SILKABK
```

Opsional (default): `DB_DATABASE=spk_uptd`, `DB_USERNAME=spk_user`, `FRONTEND_PORT=8810`,
`BACKEND_PORT=8809`, `SESSION_SECURE_COOKIE=true`, `APP_DEBUG=false`, `UPTD_NETWORK=uptd-network`.

## Portainer

Stacks → Add stack → **Repository**: URL repo ini, reference `refs/heads/testing-deploy`,
compose path `docker-compose.yml`, isi Environment variables di atas → Deploy.

## Docker CLI

```bash
git clone -b testing-deploy https://github.com/UstadzApuy/spk-skrining-anak-v2.git
cd spk-skrining-anak-v2
cp .env.example .env && nano .env
docker compose up -d --build
```

Saat pertama kali, `db` me-restore `Database_UPTD_BLK-ABK.sql`. Setiap start, backend menjalankan
migration lalu `php artisan silkabk:sync` (pasien & akun wali dari SILKABK).

Reverse proxy: `spk.domain.id` → `http://<ip-server>:8810` (host harus beda dari SILKABK).
