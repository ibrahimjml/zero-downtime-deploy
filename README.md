# Zero-Downtime CI/CD for Laravel on CloudPanel

Ship Laravel updates to CloudPanel with zero downtime. Every push builds a new release, installs dependencies in isolation, and atomically swaps the `current` symlink.

## Features

- **Safe by default — no partial deploys.** If any step fails (composer, build, migrations, healthcheck), the new release is automatically deleted before traffic ever reaches it. Nothing changes on the live site.
- **Instant rollback.** Switch back to the previous release in seconds, or roll back to any specific release by name:
  ```bash
  .deploy/deploy/rollback.sh
  .deploy/deploy/rollback.sh 20261028135516
  ```

## Setup

1. **A connected VPS from any provider** — SSH access with a user that can run the deploy scripts.
2. **An existing site in CloudPanel** — the document root will point to the `public` symlink.
3. **GitHub repository secrets configured:**
   - `VPS_HOST` — server IP or hostname
   - `VPS_USER` — SSH user
   - `VPS_SSH_KEY` — private SSH key
   - `VPS_APP_DIR` — absolute app path (e.g. `/home/site-name/htdocs/your-site.com`)
   - `PRODUCTION_ENV` — full contents of the production `.env` — secure encoded env
   - `SKIP_ASSETS` *(optional)* — set to `1` to skip the frontend asset build
   - `KEEP_RELEASES` *(optional)* — by default max releases set to 5 , you can increase as you want
4. **CloudPanel site ready for symlinked releases** — document root set to the app's `public` directory so the `public -> current/public` symlink is served.

## Installation

1. Clone this repository into your home directory:
   ```bash
   git clone https://github.com/<your-org>/zero-downtime-deploy.git ~/zero-downtime-deploy
   ```

2. Copy `.github` and `.deploy` into the root of your Laravel project:
   ```bash
   cp -r ~/zero-downtime-deploy/.github ~/zero-downtime-deploy/.deploy /path/to/your-laravel-project/
   ```

3. Commit the copied files and push to the `deploy` branch to trigger the workflow.

## Site Structure

```
# /home/site-name/htdocs/your-site.com
#     ├── .deploy/        -> stable deployment toolkit (uploaded by CI)
#     ├── current         -> releases/<timestamp>
#     ├── public          -> current/public (CloudPanel document root)
#     ├── releases/
#     ├── shared/         -> shared (storage/.env) across all releases
#         │ ├── .env
#         │ └── storage/
#     └── repo/           -> bare git repository
```
