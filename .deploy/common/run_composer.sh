run_composer() {
    local composer_path="$COMPOSER_BIN"

    if [ "${composer_path#/}" = "$composer_path" ]; then
        composer_path="$(command -v "$composer_path" 2>/dev/null || true)"
    fi

    [ -n "$composer_path" ] && [ -f "$composer_path" ] || die "Composer not found: $COMPOSER_BIN"

    local shebang
    shebang="$(head -n 1 "$composer_path" 2>/dev/null || true)"

    if printf '%s' "$shebang" | grep -qE '^#!.*php'; then
        "$PHP_BIN" "$composer_path" "$@"
    elif printf '%s' "$shebang" | grep -qE '^#!'; then
        "$composer_path" "$@"
    else
        "$PHP_BIN" "$composer_path" "$@"
    fi
}
