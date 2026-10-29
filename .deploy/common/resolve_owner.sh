resolve_owner() {
    if [ -z "$APP_USER" ]; then
        if [ "$(id -u)" -eq 0 ]; then
            APP_USER="$(stat -c '%U' "$APP_DIR" 2>/dev/null || printf 'root')"
        else
            APP_USER="$(id -un)"
        fi
    fi

    if [ -z "$APP_GROUP" ]; then
        APP_GROUP="$(id -gn "$APP_USER" 2>/dev/null || id -gn 2>/dev/null || id -g)"
    fi
}
