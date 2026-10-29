cleanup_releases() {
    local current_real dir count=0

    current_real="$(readlink -f "$CURRENT_LINK" 2>/dev/null || true)"

    while IFS= read -r dir; do
        dir="${dir%/}"
        count=$((count + 1))

        if [ "$count" -le "$KEEP_RELEASES" ]; then
            continue
        fi

        if [ "$dir" = "$current_real" ]; then
            continue
        fi

        log "Removing old release $(basename "$dir")"
        rm -rf "$dir"
    done < <(ls -1dt "$RELEASES_DIR"/*/ 2>/dev/null || true)
}
