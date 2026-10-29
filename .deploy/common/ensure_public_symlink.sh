ensure_public_symlink() {
    local stamp
    stamp="$(date -u +%Y%m%d%H%M%S)"

    if [ -L "$PUBLIC_LINK" ]; then
        if [ "$(readlink "$PUBLIC_LINK")" != "current/public" ]; then
            ln -sfn "current/public" "$PUBLIC_LINK"
        fi
    elif [ -e "$PUBLIC_LINK" ]; then
        mv "$PUBLIC_LINK" "$APP_DIR/public.legacy.$stamp"
        ln -s "current/public" "$PUBLIC_LINK"
        log "Moved legacy public directory to public.legacy.$stamp"
    else
        ln -s "current/public" "$PUBLIC_LINK"
    fi
}
