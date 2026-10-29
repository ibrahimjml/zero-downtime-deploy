link_shared() {
    rm -rf "$RELEASE_DIR/storage" "$RELEASE_DIR/.env"
    ln -s "$SHARED_STORAGE" "$RELEASE_DIR/storage"
    ln -s "$SHARED_ENV" "$RELEASE_DIR/.env"

    mkdir -p "$RELEASE_DIR/bootstrap/cache"
    chmod 775 "$RELEASE_DIR/bootstrap/cache"
    find "$RELEASE_DIR/bootstrap/cache" -type f -exec chmod 664 {} +

    if [ -d "$SHARED_STORAGE/app/public" ]; then
        rm -rf "$RELEASE_DIR/public/storage"
        ln -s "$SHARED_STORAGE/app/public" "$RELEASE_DIR/public/storage"
    fi
}
