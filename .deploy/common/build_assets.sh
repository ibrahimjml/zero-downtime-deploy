build_assets() {
    if [ "$SKIP_ASSETS" = "1" ]; then
        warn "SKIP_ASSETS=1; skipping frontend asset build"
        return
    fi

    if [ ! -f "$RELEASE_DIR/package.json" ]; then
        return
    fi

    if ! command -v npm >/dev/null 2>&1; then
        warn "npm is not available; skipping asset build. Install Node.js or set SKIP_ASSETS=1."
        return
    fi

    log "Building frontend assets"
    if [ -f "$RELEASE_DIR/package-lock.json" ]; then
        (cd "$RELEASE_DIR" && npm ci --no-audit --no-fund)
    else
        (cd "$RELEASE_DIR" && npm install --no-audit --no-fund)
    fi
    (cd "$RELEASE_DIR" && npm run build)
}
