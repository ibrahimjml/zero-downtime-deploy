reload_php_fpm() {
    if command -v systemctl >/dev/null 2>&1 \
        && command -v sudo >/dev/null 2>&1; then
            
        if sudo -n systemctl reload "$PHP_FPM_SERVICE"; then
            log "Reloaded $PHP_FPM_SERVICE"
        else
            warn "Could not reload $PHP_FPM_SERVICE"
        fi
    else
        warn "Skipping $PHP_FPM_SERVICE reload (passwordless sudo unavailable). PHP's realpath cache may serve the old release until it expires. Add .deploy/sudoers.example as root or keep opcache.validate_timestamps=1."
    fi
}
