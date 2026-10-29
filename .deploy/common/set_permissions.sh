set_permissions() {
    resolve_owner

    if [ "$(id -u)" -eq 0 ]; then
        chown -R "$APP_USER:$APP_GROUP" "$APP_DIR"
    fi

    chmod 755 "$APP_DIR" "$RELEASES_DIR" "$SHARED_DIR" "$REPO_DIR" "$SCRIPT_DIR"
    find "$SCRIPT_DIR" -type d -exec chmod 755 {} +
    find "$SCRIPT_DIR" -type f -name '*.sh' -exec chmod 755 {} +
    chmod 600 "$SHARED_ENV"

    find "$SHARED_STORAGE" -type d -exec chmod 775 {} +
    find "$SHARED_STORAGE" -type f -exec chmod 664 {} +
}
