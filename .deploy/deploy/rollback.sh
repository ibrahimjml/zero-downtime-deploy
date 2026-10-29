#!/usr/bin/env bash
#
# Instant rollback to the previous release (or to an explicit release name):
#   .deploy/deploy/rollback.sh
#   .deploy/deploy/rollback.sh 20261028135516
#
# Keep migrations without rolling back.

set -euo pipefail

DEPLOY_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../common/load_common.sh
source "$DEPLOY_DIR/../common/load_common.sh"

[ -d "$RELEASES_DIR" ] || die "Releases directory not found: $RELEASES_DIR"
[ -L "$CURRENT_LINK" ] || die "$CURRENT_LINK is not a symlink; nothing to roll back"

CURRENT_RELEASE="$(readlink "$CURRENT_LINK")"
CURRENT_NAME="$(basename "$CURRENT_RELEASE")"
CURRENT_REAL="$(readlink -f "$CURRENT_LINK")"

if [ "$#" -gt 0 ]; then
    case "$1" in
        /*) target="$1" ;;
        releases/*) target="$APP_DIR/$1" ;;
        *) target="$RELEASES_DIR/$1" ;;
    esac
else
    previous="$(
        ls -1t "$RELEASES_DIR" \
            | grep -vx "$CURRENT_NAME" \
            | sed -n 1p
    )"

    [ -n "$previous" ] || die "No previous release found"
    target="$RELEASES_DIR/$previous"
fi

[ -d "$target" ] || die "Release not found: $target"

target="$(readlink -f "$target")"
target_name="$(basename "$target")"

[ "$target" != "$CURRENT_REAL" ] || die "Already on release $target_name"

log "Rolling back from $CURRENT_NAME to $target_name"
switch_current "$target_name"

reload_php_fpm
restart_queue_workers "$target"
healthcheck

log "Rollback complete: $target_name"
log "Active release: $(readlink "$CURRENT_LINK")"
