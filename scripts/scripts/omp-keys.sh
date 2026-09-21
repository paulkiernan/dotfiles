#!/usr/bin/env bash
# Interactively set omp provider API keys in ~/.omp/agent/.env.
#
# Values are read silently, never echoed back, and never passed as command
# arguments (so they stay out of `ps` and your shell history). Existing values
# are shown masked; pressing Enter alone keeps the current one.
#
#   ~/scripts/omp-keys.sh
set -euo pipefail

ENV_FILE="${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}/.env"
EXAMPLE="${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}/.env.example"
KEYS=(DEEPSEEK_API_KEY ANTHROPIC_API_KEY GEMINI_API_KEY TYPESAFE_API_KEY)

if [ ! -f "$ENV_FILE" ]; then
    umask 077
    if [ -f "$EXAMPLE" ]; then
        cp "$EXAMPLE" "$ENV_FILE"
        echo "created $ENV_FILE from .env.example"
    else
        : > "$ENV_FILE"
        echo "created empty $ENV_FILE"
    fi
    chmod 600 "$ENV_FILE"
fi

mask() {
    local v="${1-}" n=${#1}
    if   [ "$n" -eq 0 ]; then printf '(unset)'
    elif [ "$n" -le 8 ]; then printf '**** (%d chars)' "$n"
    else printf '%s…%s (%d chars)' "${v:0:4}" "${v: -2}" "$n"
    fi
}

current() { sed -n "s/^$1=//p" "$ENV_FILE" | head -1; }

set_key() {
    local k="$1" v="$2" tmp
    tmp="$(mktemp "$ENV_FILE.XXXXXX")"
    chmod 600 "$tmp"
    if grep -q "^$k=" "$ENV_FILE"; then
        while IFS= read -r line || [ -n "$line" ]; do
            case "$line" in
                "$k="*) printf '%s=%s\n' "$k" "$v" ;;
                *)      printf '%s\n' "$line" ;;
            esac
        done < "$ENV_FILE" > "$tmp"
    else
        cat "$ENV_FILE" > "$tmp"
        printf '%s=%s\n' "$k" "$v" >> "$tmp"
    fi
    mv "$tmp" "$ENV_FILE"
    chmod 600 "$ENV_FILE"
}

echo
echo "omp API keys -> $ENV_FILE"
echo "Type a value to set it; press Enter alone to keep the current one."
echo

changed=0
for k in "${KEYS[@]}"; do
    printf '  %-18s %s\n' "$k" "$(mask "$(current "$k")")"
    printf '  new value: '
    IFS= read -rs val || true
    echo
    if [ -z "${val:-}" ]; then
        echo "    unchanged"
        echo
        continue
    fi
    # Anthropic Console keys start with sk-ant-. A Max/Pro OAuth token is not a
    # usable value here — see the "Auth" section of omp/README.md.
    if [ "$k" = "ANTHROPIC_API_KEY" ] && [ "${val#sk-ant-}" = "$val" ]; then
        echo "    note: does not look like a Console key (expected sk-ant-…). Saving anyway."
    fi
    set_key "$k" "$val"
    changed=$((changed + 1))
    echo "    set"
    echo
done

echo "$changed key(s) updated. $ENV_FILE is mode $(stat -f '%Lp' "$ENV_FILE" 2>/dev/null || stat -c '%a' "$ENV_FILE")."
echo
echo "openai-codex takes no key — run 'omp' and then '/login openai-codex'."
echo "Smoke test once keys are in:  omp -p 'hey'"
