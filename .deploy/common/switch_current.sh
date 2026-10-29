switch_current() {
    local release_name="$1"

    if [ -e "$CURRENT_LINK" ] && [ ! -L "$CURRENT_LINK" ]; then
        mv "$CURRENT_LINK" "$APP_DIR/current.legacy.$(date -u +%Y%m%d%H%M%S)"
    fi

    ln -sfn "releases/$release_name" "$CURRENT_LINK"
    ensure_public_symlink
}
