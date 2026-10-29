ensure_env() {
    mkdir -p "$SHARED_DIR"

    # First run on an existing CloudPanel app: adopt its production .env.
    if [ ! -s "$SHARED_ENV" ] && [ -f "$APP_DIR/.env" ]; then
        sed 's/\r$//' "$APP_DIR/.env" >"$SHARED_ENV"
        log "Migrated legacy $APP_DIR/.env to $SHARED_ENV"
    fi

    if [ ! -s "$SHARED_ENV" ]; then
        if [ -n "${PRODUCTION_ENV_B64:-}" ]; then
            local tmp_env
            tmp_env="$(mktemp "$SHARED_DIR/.env.XXXXXX")"
            printf '%s' "$PRODUCTION_ENV_B64" | base64 -d | sed 's/\r$//' >"$tmp_env"
            mv "$tmp_env" "$SHARED_ENV"
            log "Created $SHARED_ENV from the PRODUCTION_ENV secret"
        else
            die "Missing $SHARED_ENV. Add a PRODUCTION_ENV repository secret containing the production .env, or create the file on the server."
        fi
    fi

    chmod 600 "$SHARED_ENV"

    if ! grep -qE '^APP_KEY=base64:.+' "$SHARED_ENV"; then
        local app_key
        app_key="base64:$("$PHP_BIN" -r 'echo base64_encode(random_bytes(32));')"

        if grep -qE '^APP_KEY=' "$SHARED_ENV"; then
            sed -i -E "s#^APP_KEY=.*#APP_KEY=${app_key}#" "$SHARED_ENV"
        else
            printf '\nAPP_KEY=%s\n' "$app_key" >>"$SHARED_ENV"
        fi

        log "Generated APP_KEY in $SHARED_ENV"
    fi
}
