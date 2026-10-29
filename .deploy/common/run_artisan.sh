run_artisan() {
    local release_dir="$1"
    shift
    (cd "$release_dir" && "$PHP_BIN" artisan "$@")
}
