#!/bin/bash
set -euo pipefail

SERVICE="com.nicolasalonso.SUPRA.external"
BUNDLE_ID="com.nicolasalonso.SUPRA"

usage(){
  cat <<'EOF'
Usage:
  CONFIGURE_OFFICIAL_CONNECTOR_SECRETS_V1.sh status
  CONFIGURE_OFFICIAL_CONNECTOR_SECRETS_V1.sh x-read
  CONFIGURE_OFFICIAL_CONNECTOR_SECRETS_V1.sh inpi
  CONFIGURE_OFFICIAL_CONNECTOR_SECRETS_V1.sh clear-x
  CONFIGURE_OFFICIAL_CONNECTOR_SECRETS_V1.sh clear-inpi

Secrets are stored only in macOS Keychain.
INPI base URL is stored as a non-secret application preference.
EOF
}

has_keychain_item(){
  /usr/bin/security find-generic-password -s "$SERVICE" -a "$1" >/dev/null 2>&1
}

set_secret(){
  local account="$1"
  local prompt="$2"
  local value=""
  printf '%s' "$prompt" >/dev/tty
  IFS= read -r -s value </dev/tty
  printf '\n' >/dev/tty
  [ -n "$value" ] || { printf 'EMPTY_VALUE\n' >&2; exit 10; }
  /usr/bin/security add-generic-password -U -s "$SERVICE" -a "$account" -w "$value" >/dev/null
  unset value
}

case "${1:-}" in
  status)
    printf 'X_BEARER=%s\n' "$(has_keychain_item x.bearerToken && echo CONFIGURED || echo MISSING)"
    printf 'INPI_AUTH=%s\n' "$(has_keychain_item inpi.authorizationHeader && echo CONFIGURED || echo MISSING)"
    BASE="$(/usr/bin/defaults read "$BUNDLE_ID" SUPRA_INPI_API_BASE_URL 2>/dev/null || true)"
    printf 'INPI_BASE_URL=%s\n' "${BASE:-MISSING}"
    ;;

  x-read)
    set_secret "x.bearerToken" "Paste X API bearer token (input hidden): "
    printf 'STATUS=X_READ_CREDENTIAL_CONFIGURED\n'
    ;;

  inpi)
    printf 'Paste official INPI API base URL from your Data INPI technical documentation: ' >/dev/tty
    IFS= read -r BASE </dev/tty
    case "$BASE" in
      https://*) ;;
      *) printf 'INVALID_INPI_BASE_URL\n' >&2; exit 20 ;;
    esac
    /usr/bin/defaults write "$BUNDLE_ID" SUPRA_INPI_API_BASE_URL "$BASE"
    set_secret "inpi.authorizationHeader" "Paste complete INPI Authorization header value (input hidden): "
    printf 'STATUS=INPI_OFFICIAL_CREDENTIAL_CONFIGURED\n'
    ;;

  clear-x)
    /usr/bin/security delete-generic-password -s "$SERVICE" -a "x.bearerToken" >/dev/null 2>&1 || true
    printf 'STATUS=X_CREDENTIAL_CLEARED\n'
    ;;

  clear-inpi)
    /usr/bin/security delete-generic-password -s "$SERVICE" -a "inpi.authorizationHeader" >/dev/null 2>&1 || true
    /usr/bin/defaults delete "$BUNDLE_ID" SUPRA_INPI_API_BASE_URL >/dev/null 2>&1 || true
    printf 'STATUS=INPI_CREDENTIAL_CLEARED\n'
    ;;

  *)
    usage
    exit 2
    ;;
esac
