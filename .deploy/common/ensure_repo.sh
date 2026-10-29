ensure_repo() {
    if [ ! -d "$REPO_DIR/objects" ]; then
        git init --bare "$REPO_DIR" >/dev/null
    fi

    # Replace https://x-access-token: to clean url https://
    # Never persist credentials from a tokenized https://x-access-token:... URL.
    local clean_url
    clean_url="$(printf '%s' "$GIT_REPO" | sed -E 's#^(https?://)[^/@]+@#\1#')"

    if git --git-dir="$REPO_DIR" remote get-url origin >/dev/null 2>&1; then
        git --git-dir="$REPO_DIR" remote set-url origin "$clean_url"
    else
        git --git-dir="$REPO_DIR" remote add origin "$clean_url"
    fi
}
