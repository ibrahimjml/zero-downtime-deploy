restart_queue_workers() {
    local release_dir="${1:-$RELEASE_DIR}"

    if [ -f "$release_dir/artisan" ]; then
        (cd "$release_dir" && "$PHP_BIN" artisan queue:restart)
        log "Signalled queue workers to restart"
    fi
}
