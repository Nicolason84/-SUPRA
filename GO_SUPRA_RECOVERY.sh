#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="${SUPRA_ROOT:-$(cd "$(dirname "$0")" && pwd)}"
BACKUPS="${ROOT}/_SUPRA_BACKUPS"
LOG="${ROOT}/Logs/recovery_$(date +%Y%m%d_%H%M%S).log"

echo "SUPRA Recovery — $(date)"
echo "Root  : ${ROOT}"
echo "Log   : ${LOG}"

# Trouver le backup le plus récent
LATEST_BACKUP=$(find "$BACKUPS" -maxdepth 1 -type d -name 'bootstrap_*' | sort | tail -1)

if [ -z "$LATEST_BACKUP" ]; then
    echo "[!] Aucun backup trouvé dans ${BACKUPS}"
    exit 1
fi

echo "[→] Récupération depuis : ${LATEST_BACKUP}"

# Restaurer les fichiers
if [ -d "${LATEST_BACKUP}${ROOT}" ]; then
    cp -R "${LATEST_BACKUP}${ROOT}/"* "$ROOT/" 2>/dev/null || true
    echo "[✓] Fichiers restaurés"
fi

# Restaurer la config OpenCode
CONFIG_BACKUP="${LATEST_BACKUP}$HOME/.config/opencode/opencode.json"
if [ -f "$CONFIG_BACKUP" ]; then
    cp "$CONFIG_BACKUP" "$HOME/.config/opencode/opencode.json"
    echo "[✓] Configuration OpenCode restaurée"
fi

echo "[✓] Récupération terminée"
