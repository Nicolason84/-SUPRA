#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="${SUPRA_ROOT:-$(cd "$(dirname "$0")" && pwd)}"
BACKUP_DIR="${ROOT}/_SUPRA_BACKUPS"
CONFIG_DIR="${HOME}/.config/opencode"
LOG="${ROOT}/Logs/uninstall_$(date +%Y%m%d_%H%M%S).log"

echo "╔══════════════════════════════════════════╗"
echo "║  SUPRA NODE — DÉSINSTALLATION             "
echo "╚══════════════════════════════════════════╝"
echo
echo "Ce script va désinstaller SUPRA de cette machine."
echo "  Root  : ${ROOT}"
echo "  Backup: ${BACKUP_DIR}"
echo "  Config: ${CONFIG_DIR}"
echo "  Log   : ${LOG}"
echo
echo "ATTENTION : Cette action est irréversible."
echo "Taper 'desinstaller' pour confirmer."
echo

read -r CONFIRM
if [ "$CONFIRM" != "desinstaller" ]; then
    echo "Annulé."
    exit 0
fi

exec 3>&1 1>>"$LOG" 2>&1

echo "[→] Sauvegarde finale..."
FINAL_BACKUP="${BACKUP_DIR}/pre_uninstall_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$FINAL_BACKUP"
[ -d "$ROOT" ] && cp -R "$ROOT" "${FINAL_BACKUP}/SUPRA" 2>/dev/null || true
[ -f "${CONFIG_DIR}/opencode.json" ] && cp "${CONFIG_DIR}/opencode.json" "${FINAL_BACKUP}/" 2>/dev/null || true
echo "[✓] Sauvegarde dans ${FINAL_BACKUP}"

echo "[→] Suppression de la configuration OpenCode..."
rm -f "${CONFIG_DIR}/opencode.json" 2>/dev/null || true
echo "[✓] Configuration supprimée"

echo "[→] Arrêt d'Ollama..."
pkill -x ollama 2>/dev/null || true
sleep 1
echo "[✓] Ollama arrêté"

echo "[→] Suppression de la racine SUPRA..."
rm -rf "$ROOT" 2>/dev/null || true
echo "[✓] Racine supprimée : ${ROOT}"

echo
echo "╔══════════════════════════════════════════╗"
echo "║  SUPRA désinstallé                        "
echo "║  Backup conservé dans :                   "
echo "║    ${FINAL_BACKUP}"
echo "╚══════════════════════════════════════════╝"
