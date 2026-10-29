#!/usr/bin/env bash
#
# Loads every shared helper and variable used by the deployment scripts.
# Source this file from deploy.sh and rollback.sh.

set -euo pipefail

COMMON_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$(cd -- "$COMMON_DIR/.." && pwd)"

source "$COMMON_DIR/helpers.sh"
source "$COMMON_DIR/parsing_names.sh"

source "$COMMON_DIR/run_composer.sh"
source "$COMMON_DIR/run_artisan.sh"
source "$COMMON_DIR/resolve_owner.sh"
source "$COMMON_DIR/acquire_lock.sh"
source "$COMMON_DIR/ensure_dirs.sh"
source "$COMMON_DIR/migrate_legacy_storage.sh"
source "$COMMON_DIR/ensure_repo.sh"
source "$COMMON_DIR/ensure_env.sh"
source "$COMMON_DIR/set_permissions.sh"
source "$COMMON_DIR/link_shared.sh"
source "$COMMON_DIR/ensure_public_symlink.sh"
source "$COMMON_DIR/switch_current.sh"
source "$COMMON_DIR/reload_php_fpm.sh"
source "$COMMON_DIR/restart_queue_workers.sh"
source "$COMMON_DIR/build_assets.sh"
source "$COMMON_DIR/healthcheck.sh"
source "$COMMON_DIR/cleanup_releases.sh"
