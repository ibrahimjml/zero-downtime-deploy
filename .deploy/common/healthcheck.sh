healthcheck() {
    if [ -z "$HEALTHCHECK_URL" ]; then
        return
    fi

    if ! command -v curl >/dev/null 2>&1; then
        warn "curl is unavailable; skipping health check"
        return
    fi

    if curl -fsS --max-time 10 -o /dev/null "$HEALTHCHECK_URL"; then
        log "Health check passed: $HEALTHCHECK_URL"
    else
        warn "Health check failed: $HEALTHCHECK_URL"
    fi
}
