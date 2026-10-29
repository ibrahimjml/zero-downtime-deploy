ensure_dirs() {
    mkdir -p \
        "$RELEASES_DIR" \
        "$SHARED_STORAGE/app/public" \
        "$SHARED_STORAGE/framework/cache/data" \
        "$SHARED_STORAGE/framework/sessions" \
        "$SHARED_STORAGE/framework/views" \
        "$SHARED_STORAGE/logs" \
        "$REPO_DIR"
}
