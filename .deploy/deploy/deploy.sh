#!/usr/bin/env bash
#
# Zero-downtime deployment:
#   1. fetch into the bare repository
#   2. create a new release directory
#   3. link shared storage/.env and install dependencies in isolation
#   4. atomically switch the `current` symlink
#   5. reload PHP-FPM / restart queue workers
#   6. remove old releases

set -euo pipefail

DEPLOY_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../common/load_common.sh
source "$DEPLOY_DIR/../common/load_common.sh"

on_exit() {
    local status=$?
    trap - EXIT

    if [ "$status" -ne 0 ] && [ -n "$RELEASE_DIR" ] && [ -d "$RELEASE_DIR" ]; then
        local current_real
        current_real="$(readlink -f "$CURRENT_LINK" 2>/dev/null || true)"

        if [ "$current_real" != "$RELEASE_DIR" ]; then
            warn "Deployment failed; removing incomplete release $(basename "$RELEASE_DIR")"
            rm -rf "$RELEASE_DIR"
        fi
    fi

    exit "$status"
}

trap on_exit EXIT

mkdir -p "$APP_DIR"
acquire_lock
ensure_dirs
migrate_legacy_storage
ensure_repo

command -v "$PHP_BIN" >/dev/null 2>&1 || die "PHP binary not found: $PHP_BIN"

ensure_env
set_permissions

if [ "${COMPOSER_BIN##*.}" = "phar" ]; then
    [ -f "$COMPOSER_BIN" ] || die "Composer phar not found: $COMPOSER_BIN"
else
    command -v "$COMPOSER_BIN" >/dev/null 2>&1 || die "Composer not found: $COMPOSER_BIN"
fi

clean_repo_url="$(printf '%s' "$GIT_REPO" | sed -E 's#^(https?://)[^/@]+@#\1#')"
log "Fetching $BRANCH from $clean_repo_url"
GIT_TERMINAL_PROMPT=0 git --git-dir="$REPO_DIR" fetch --prune \
    "$GIT_REPO" "+refs/heads/$BRANCH:refs/remotes/origin/$BRANCH"

COMMIT="$(git --git-dir="$REPO_DIR" rev-parse "refs/remotes/origin/$BRANCH")"
RELEASE="$(date -u +%Y%m%d%H%M%S)"
RELEASE_DIR="$RELEASES_DIR/$RELEASE"

log "Creating release $RELEASE ($COMMIT)"
mkdir -p "$RELEASE_DIR"
git --git-dir="$REPO_DIR" archive --format=tar "$COMMIT" | tar -x -C "$RELEASE_DIR"

log "Linking shared storage and environment"
link_shared

log "Installing Composer dependencies"
(cd "$RELEASE_DIR" && run_composer install \
    --no-dev \
    --prefer-dist \
    --optimize-autoloader \
    --no-interaction \
    --no-progress)

build_assets

log "Caching Laravel configuration"
run_artisan "$RELEASE_DIR" config:cache
run_artisan "$RELEASE_DIR" view:cache
run_artisan "$RELEASE_DIR" event:cache

# routes/api.php contains a closure, so route:cache can legitimately fail.
if ! run_artisan "$RELEASE_DIR" route:cache; then
    warn "route:cache failed (closure routes are not cacheable); clearing route cache"
    run_artisan "$RELEASE_DIR" route:clear || true
fi

log "Running database migrations"
run_artisan "$RELEASE_DIR" migrate --force --no-interaction

log "Setting release permissions"
chmod -R u+rwX,go+rX "$RELEASE_DIR"
chmod 775 "$RELEASE_DIR/bootstrap/cache"
find "$RELEASE_DIR/bootstrap/cache" -type f -exec chmod 664 {} +

log "Switching current -> releases/$RELEASE"
switch_current "$RELEASE"

reload_php_fpm
restart_queue_workers "$RELEASE_DIR"
healthcheck
cleanup_releases || warn "Could not prune old releases"

log "Deployment complete: $RELEASE"
log "Active release: $(readlink "$CURRENT_LINK")"
