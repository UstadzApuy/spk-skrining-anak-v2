# Deploy SPK Skrining Anak (terhubung ke SILKABK)

Panduan lengkap (kedua sistem) ada di repo SILKABK: `DEPLOY.md`
(`bucks23/SILKABK`, branch `testing-deploy`). Ringkasnya:

- `docker-compose.yml` di root repo ini = **produksi** (db + backend PHP-FPM + frontend Nginx).
- `compose.dev.yaml` = pengembangan (artisan serve): `docker compose -f compose.dev.yaml up -d`
- Port host: frontend **8810** (HTTP, tujuan reverse proxy), backend **8809** (FastCGI).
- Tersambung ke SILKABK lewat jaringan Docker **`uptd-network`** yang dibuat compose SILKABK.
  **Deploy SILKABK lebih dulu.**

## Langkah

```bash
git clone -b testing-deploy https://github.com/UstadzApuy/spk-skrining-anak-v2.git
cd spk-skrining-anak-v2
cp .env.example .env
nano .env
docker compose up -d --build
docker compose logs -f db backend
```

Isi di `.env`:

| Variabel | Isi |
|---|---|
| `APP_ENV` / `APP_DEBUG` / `LOG_LEVEL` | `production` / `false` / `warning` |
| `APP_URL` | `https://spk.domain.id` |
| `APP_KEY` | `docker run --rm php:8.2-cli php -r "echo 'base64:'.base64_encode(random_bytes(32)).PHP_EOL;"` |
| `DB_DATABASE` / `DB_USERNAME` / `DB_PASSWORD` | `spk_uptd` / `spk_user` / password kuat |
| `SILKABK_URL` | `https://silkabk.domain.id` |
| `SILKABK_SSO_SECRET` | **sama** dengan `SPK_SKRINING_SSO_SECRET` di `.env` SILKABK |
| `SILKABK_DB_USERNAME` / `SILKABK_DB_PASSWORD` | `spk_reader` / **sama** dengan `SPK_READER_PASSWORD` di `.env` SILKABK |
| `SESSION_SECURE_COOKIE` | `true` |

Saat pertama kali, `db` otomatis me-restore `Database_UPTD_BLK-ABK.sql`. Setiap start, backend
menjalankan migration lalu `php artisan silkabk:sync` (pasien & akun wali dari SILKABK).

Reverse proxy: `spk.domain.id` → `http://127.0.0.1:8810` (host harus beda dari SILKABK;
teruskan header `Host`, `X-Forwarded-For`, `X-Forwarded-Proto`).
