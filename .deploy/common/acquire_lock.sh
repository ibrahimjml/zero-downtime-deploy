acquire_lock() {
    if command -v flock >/dev/null 2>&1; then
        exec 200>"$LOCK_FILE"
        if ! flock -n 200; then
            die "Another deployment is already running ($LOCK_FILE)"
        fi
    else
        warn "flock is unavailable; continuing without a deployment lock"
    fi
}
