migrate_legacy_storage() {
    if [ -L "$APP_DIR/storage" ] || [ ! -d "$APP_DIR/storage/app" ]; then
        return
    fi

    if [ -n "$(find "$SHARED_STORAGE/app" -mindepth 1 -print -quit 2>/dev/null)" ]; then
        return
    fi

    log "Migrating legacy storage/app to $SHARED_STORAGE/app"
    cp -a "$APP_DIR/storage/app/." "$SHARED_STORAGE/app/"
}
