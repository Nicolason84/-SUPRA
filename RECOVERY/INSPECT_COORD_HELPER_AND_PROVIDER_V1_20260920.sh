#!/bin/bash
set -euo pipefail

ROOT="$HOME/NOVA_OS/SUPRA_CHATGPT_APP_BRIDGE_V1"
HELPER="$ROOT/CURRENT/supra_fileprovider_coordinated_read"

printf 'STATUS=COORD_HELPER_INSPECT_BEGIN\n'
printf 'HELPER=%s\n' "$HELPER"

if [ -f "$HELPER.swift" ]; then
  printf '\n=== HELPER SOURCE ===\n'
  nl -ba "$HELPER.swift" | sed -n '1,220p'
elif [ -f "$ROOT/CURRENT/supra_fileprovider_coordinated_read.swift" ]; then
  printf '\n=== HELPER SOURCE ===\n'
  nl -ba "$ROOT/CURRENT/supra_fileprovider_coordinated_read.swift" | sed -n '1,220p'
else
  printf '\n=== HELPER SOURCE NOT FOUND ===\n'
fi

printf '\n=== FILEPROVIDER DOMAINS ===\n'
/usr/bin/fileproviderctl dump -l 2>/dev/null | sed -n '1,220p' || true

printf '\n=== PENDING INBOX ===\n'
INBOX="$HOME/Library/CloudStorage/GoogleDrive-nicolas.alonsof84@gmail.com/Mon Drive/SUPRA_IMAC_MEMORY_GATEWAY/REMOTE/INBOX"
ls -lO@ "$INBOX" 2>/dev/null | tail -40 || true

printf '\n=== ERROR LOG ===\n'
tail -n 10 /tmp/SUPRA_BRIDGE_LOAD_JSON_ERRORS.jsonl 2>/dev/null || true

printf '\nSTATUS=COORD_HELPER_INSPECT_COMPLETE\n'
