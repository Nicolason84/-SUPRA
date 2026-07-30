#!/usr/bin/env bash
set -Eeuo pipefail

###############################################################################
# SUPRA BOOTSTRAP V3
# Transforme n'importe quel ordinateur en nœud SUPRA autonome.
#
# Principes :
#   - Ne jamais casser l'existant (détection avant action)
#   - Toujours réutiliser avant de recréer
#   - Tout est versionné, journalisé, réversible
#   - Aucun outil n'est obligatoire (fallback gracieux)
#   - 0 € obligatoire (uniquement outils gratuits/open-source)
#   - Tout est modulaire et remplaçable
#
# Usage :
#   curl -fsSL https://raw.githubusercontent.com/.../SUPRA_BOOTSTRAP_V3.sh | bash
#   # ou
#   bash SUPRA_BOOTSTRAP_V3.sh
###############################################################################

SCRIPT_VERSION="3.0.0"
SCRIPT_NAME="SUPRA Bootstrap V3"
START_EPOCH=$(date +%s)

# ─── Configuration ─────────────────────────────────────────────────────────
# Surchargeable via variables d'environnement
SUPRA_ROOT="${SUPRA_ROOT:-$HOME/Desktop/NOVA_OS/SUPRA}"
SUPRA_BACKUP_DIR="${SUPRA_BACKUP_DIR:-${SUPRA_ROOT}/_SUPRA_BACKUPS/bootstrap_$(date +%Y%m%d_%H%M%S)}"
SUPRA_LOG_DIR="${SUPRA_LOG_DIR:-${SUPRA_ROOT}/Logs}"
SUPRA_NODE_ID="${SUPRA_NODE_ID:-supra-node-$(hostname | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9-')}"
SUPRA_DEFAULT_MODEL="${SUPRA_DEFAULT_MODEL:-qwen3:4b}"
SUPRA_OLLAMA_PORT="${SUPRA_OLLAMA_PORT:-11434}"
SUPRA_FORCE="${SUPRA_FORCE:-false}"
SUPRA_SKIP_OLLAMA="${SUPRA_SKIP_OLLAMA:-false}"
SUPRA_SKIP_OPENCODE="${SUPRA_SKIP_OPENCODE:-false}"
SUPRA_DRY_RUN="${SUPRA_DRY_RUN:-false}"

LOG_FILE="${SUPRA_LOG_DIR}/bootstrap_$(date +%Y%m%d_%H%M%S).log"
MANIFEST_FILE="${SUPRA_ROOT}/.supra_node_manifest.json"
STATUS_FILE="${SUPRA_ROOT}/.supra_node_status.json"

PASS=0
FAIL=0
WARN=0
SKIP=0

# ─── Output Helpers ─────────────────────────────────────────────────────────
pass()  { PASS=$((PASS+1)); log "PASS: $*"; printf "  \033[32m✓\033[0m %s\n" "$*"; }
fail()  { FAIL=$((FAIL+1)); log "FAIL: $*"; printf "  \033[31m✗\033[0m %s\n" "$*"; }
warn()  { WARN=$((WARN+1)); log "WARN: $*"; printf "  \033[33m⚠\033[0m %s\n" "$*"; }
skip()  { SKIP=$((SKIP+1)); log "SKIP: $*"; printf "  \033[90m–\033[0m %s\n" "$*"; }

section() {
    printf "\n\033[1;36m═══════════════════════════════════════════════════════════════════\033[0m\n"
    printf "\033[1;36m  %s\033[0m\n" "$1"
    printf "\033[1;36m═══════════════════════════════════════════════════════════════════\033[0m\n"
    log "=== SECTION: $1 ==="
}

sub_section() {
    printf "\n  \033[1;33m▶ %s\033[0m\n" "$1"
    log "--- $1 ---"
}

info() {
    printf "    \033[90m%s\033[0m\n" "$1"
    log "INFO: $1"
}

# ─── Logging ────────────────────────────────────────────────────────────────
log() {
    local ts
    ts=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$ts] $*" >> "$LOG_FILE"
}

# ─── Preflight ──────────────────────────────────────────────────────────────
detect_platform() {
    local os arch

    case "$(uname -s)" in
        Darwin*)  os="macos"   ;;
        Linux*)   os="linux"   ;;
        CYGWIN*|MINGW*|MSYS*) os="windows" ;;
        *)        os="unknown" ;;
    esac

    case "$(uname -m)" in
        x86_64|amd64) arch="x86_64" ;;
        arm64|aarch64) arch="arm64" ;;
        *) arch="unknown" ;;
    esac

    # WSL detection
    local wsl=0
    if [ -f /proc/version ] && grep -qi microsoft /proc/version 2>/dev/null; then
        wsl=1
    fi

    echo "${os}|${arch}|${wsl}"
}

# ─── Tool Detection ─────────────────────────────────────────────────────────
tool_available() {
    command -v "$1" >/dev/null 2>&1
}

check_prerequisite() {
    local name="$1"
    local cmd="${2:-$1}"
    local min_version="${3:-}"

    if tool_available "$cmd"; then
        if [ -n "$min_version" ]; then
            local version
            version=$("$cmd" --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1 || echo "0")
            if [ "$(printf '%s\n' "$min_version" "$version" | sort -V | head -1)" = "$min_version" ]; then
                pass "$name $version (≥ $min_version)"
            else
                warn "$name $version (< $min_version recommandé)"
            fi
        else
            local version
            version=$("$cmd" --version 2>/dev/null | head -1 | tr -d '\n')
            pass "$name — ${version:-détecté}"
        fi
        return 0
    else
        fail "$name — non trouvé"
        return 1
    fi
}

# ─── Package Manager Detection ──────────────────────────────────────────────
detect_package_manager() {
    if tool_available brew; then
        echo "brew"
    elif tool_available apt-get; then
        echo "apt"
    elif tool_available dnf; then
        echo "dnf"
    elif tool_available yum; then
        echo "yum"
    elif tool_available pacman; then
        echo "pacman"
    elif tool_available apk; then
        echo "apk"
    elif tool_available winget; then
        echo "winget"
    elif tool_available scoop; then
        echo "scoop"
    else
        echo "none"
    fi
}

pm_install_cmd() {
    local pm="$1"
    shift
    case "$pm" in
        brew)   echo "brew install $*" ;;
        apt)    echo "sudo apt-get install -y $*" ;;
        dnf)    echo "sudo dnf install -y $*" ;;
        yum)    echo "sudo yum install -y $*" ;;
        pacman) echo "sudo pacman -S --noconfirm $*" ;;
        apk)    echo "sudo apk add $*" ;;
        winget) echo "winget install $*" ;;
        scoop)  echo "scoop install $*" ;;
        *)      echo "" ;;
    esac
}

# ─── Reversibility ──────────────────────────────────────────────────────────
backup_file() {
    local file="$1"
    if [ -f "$file" ]; then
        local backup_path="${SUPRA_BACKUP_DIR}${file}"
        mkdir -p "$(dirname "$backup_path")"
        cp "$file" "$backup_path"
        info "Sauvegarde : $file → $backup_path"
    fi
}

backup_directory() {
    local dir="$1"
    if [ -d "$dir" ]; then
        local backup_path="${SUPRA_BACKUP_DIR}${dir}"
        mkdir -p "$(dirname "$backup_path")"
        cp -R "$dir" "$backup_path" 2>/dev/null || true
        info "Sauvegarde : $dir → $backup_path"
    fi
}

# ─── Manifest ───────────────────────────────────────────────────────────────
write_manifest() {
    local end_epoch
    end_epoch=$(date +%s)
    local duration=$((end_epoch - START_EPOCH))

    cat > "$MANIFEST_FILE" <<MANIFEST_EOF
{
  "manifest_version": "1.0",
  "bootstrap_version": "${SCRIPT_VERSION}",
  "node_id": "${SUPRA_NODE_ID}",
  "platform": "$(detect_platform)",
  "hostname": "$(hostname)",
  "user": "$(whoami)",
  "home": "${HOME}",
  "supra_root": "${SUPRA_ROOT}",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "duration_seconds": ${duration},
  "results": {
    "pass": ${PASS},
    "fail": ${FAIL},
    "warn": ${WARN},
    "skip": ${SKIP}
  },
  "tools": {
    "bash": "$(bash --version | head -1)",
    "git": "$(git --version 2>/dev/null || echo 'non installé')",
    "curl": "$(curl --version 2>/dev/null | head -1 || echo 'non installé')",
    "ollama": "$(ollama --version 2>/dev/null || echo 'non installé')",
    "opencode": "$(opencode --version 2>/dev/null || echo 'non installé')"
  },
  "components": {
    "ollama": $( [ -n "$(ollama --version 2>/dev/null)" ] && echo '"installé"' || echo '"manquant"'),
    "opencode": $( [ -n "$(opencode --version 2>/dev/null)" ] && echo '"installé"' || echo '"manquant"'),
    "workspace": $( [ -d "$SUPRA_ROOT/Missions" ] && echo '"initialisé"' || echo '"non initialisé"'),
    "config": $( [ -f "$HOME/.config/opencode/opencode.json" ] && echo '"configuré"' || echo '"non configuré"'),
    "kernel": $( [ -d "$SUPRA_ROOT/.kernel" ] && echo '"initialisé"' || echo '"non initialisé"'),
    "models": $( curl -sf http://127.0.0.1:${SUPRA_OLLAMA_PORT}/api/tags >/dev/null 2>&1 && echo '"disponibles"' || echo '"indisponibles"')
  },
  "backup_dir": "${SUPRA_BACKUP_DIR}"
}
MANIFEST_EOF
    log "Manifeste écrit : $MANIFEST_FILE"
}

write_status() {
    cat > "$STATUS_FILE" <<STATUS_EOF
{
  "node_id": "${SUPRA_NODE_ID}",
  "version": "${SCRIPT_VERSION}",
  "state": "$( [ ${FAIL} -eq 0 ] && echo 'ready' || echo 'degraded' )",
  "updated_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "pass": ${PASS},
  "fail": ${FAIL},
  "warn": ${WARN}
}
STATUS_EOF
    log "Statut écrit : $STATUS_FILE"
}

# ═══════════════════════════════════════════════════════════════════════════
# COMPOSANTS
# ═══════════════════════════════════════════════════════════════════════════

# ─── 1. Platform Detection ─────────────────────────────────────────────────
component_platform() {
    section "1/8 — DÉTECTION DE LA PLATEFORME"

    local platform
    platform=$(detect_platform)
    local os arch wsl
    IFS='|' read -r os arch wsl <<< "$platform"

    info "OS    : ${os}"
    info "Arch  : ${arch}"
    info "WSL   : $([ "$wsl" = 1 ] && echo 'oui' || echo 'non')"
    info "Shell : ${SHELL}"
    info "User  : $(whoami)@$(hostname)"
    info "Home  : ${HOME}"
    info "Root  : ${SUPRA_ROOT}"

    if [ "$os" = "unknown" ] || [ "$arch" = "unknown" ]; then
        fail "Plateforme non reconnue : $(uname -a)"
        return 1
    fi
    pass "Plateforme : ${os}/${arch}"

    local pm
    pm=$(detect_package_manager)
    if [ "$pm" != "none" ]; then
        pass "Package manager : ${pm}"
    else
        warn "Aucun package manager détecté (installations manuelles nécessaires)"
    fi

    # Vérifier les droits d'écriture
    if [ -w "$(dirname "$SUPRA_ROOT" 2>/dev/null || echo "$HOME")" ]; then
        pass "Droits d'écriture : OK"
    else
        fail "Pas de droits d'écriture sur ${SUPRA_ROOT}"
        return 1
    fi
}

# ─── 2. Prerequisites ──────────────────────────────────────────────────────
component_prerequisites() {
    section "2/8 — PRÉREQUIS"

    local pm
    pm=$(detect_package_manager)

    check_prerequisite "Bash" "bash" "4.0"
    check_prerequisite "Git" "git" "2.0"
    check_prerequisite "cURL" "curl"

    # OpenCode
    if ! check_prerequisite "OpenCode CLI" "opencode"; then
        if [ "$pm" != "none" ] && [ "$SUPRA_SKIP_OPENCODE" != "true" ]; then
            info "Installation possible via : npm install -g @opencode/cli"
            warn "OpenCode non installé — lancer 'npm install -g @opencode/cli' manuellement"
        fi
    fi

    # Ollama
    if ! check_prerequisite "Ollama" "ollama"; then
        if [ "$SUPRA_SKIP_OLLAMA" != "true" ]; then
            case "$(detect_platform | cut -d'|' -f1)" in
                macos)
                    if [ "$pm" = "brew" ]; then
                        info "Installation recommandée : brew install ollama"
                    else
                        info "Installation : https://ollama.ai/download/mac"
                    fi
                    ;;
                linux)
                    info "Installation : curl -fsSL https://ollama.ai/install.sh | sh"
                    ;;
                windows)
                    info "Installation : https://ollama.ai/download/windows"
                    ;;
            esac
            warn "Ollama non installé"
        fi
    fi

    # jq (optionnel, pour manipuler le JSON)
    check_prerequisite "jq" "jq"
}

# ─── 3. Ollama Service ─────────────────────────────────────────────────────
component_ollama() {
    section "3/8 — SERVICE OLLAMA"

    if [ "$SUPRA_SKIP_OLLAMA" = "true" ]; then
        skip "Ollama désactivé via SUPRA_SKIP_OLLAMA"
        return 0
    fi

    if ! tool_available ollama; then
        fail "Ollama non installé — ignorer ou installer d'abord"
        return 1
    fi

    # Démarrer si pas déjà en cours
    if ! pgrep -x ollama >/dev/null 2>&1; then
        info "Démarrage du service Ollama..."
        ollama serve >/dev/null 2>&1 &
        local wait_max=10
        local waited=0
        while [ $waited -lt $wait_max ]; do
            if curl -sf http://127.0.0.1:${SUPRA_OLLAMA_PORT}/api/tags >/dev/null 2>&1; then
                break
            fi
            sleep 1
            waited=$((waited + 1))
        done
        if curl -sf http://127.0.0.1:${SUPRA_OLLAMA_PORT}/api/tags >/dev/null 2>&1; then
            pass "Service Ollama démarré (port ${SUPRA_OLLAMA_PORT})"
        else
            fail "Impossible de démarrer Ollama après ${wait_max}s"
            return 1
        fi
    else
        pass "Service Ollama déjà en cours"
    fi

    # Lister les modèles disponibles
    sub_section "Modèles disponibles"
    local models
    models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
    if [ -z "$models" ]; then
        warn "Aucun modèle Ollama installé"
        info "Téléchargement de ${SUPRA_DEFAULT_MODEL}..."
        if ollama pull "$SUPRA_DEFAULT_MODEL" 2>&1 | tail -5 >> "$LOG_FILE"; then
            pass "Modèle téléchargé : ${SUPRA_DEFAULT_MODEL}"
        else
            fail "Échec du téléchargement : ${SUPRA_DEFAULT_MODEL}"
        fi
    else
        info "$(echo "$models" | wc -l | tr -d ' ') modèle(s) disponible(s) :"
        echo "$models" | while read -r m; do
            info "  - ${m}"
        done
        pass "Modèles Ollama disponibles"
    fi

    # Test API
    if curl -sf http://127.0.0.1:${SUPRA_OLLAMA_PORT}/api/tags >/dev/null 2>&1; then
        pass "API Ollama répond sur 127.0.0.1:${SUPRA_OLLAMA_PORT}"
    else
        fail "API Ollama injoignable"
    fi
}

# ─── 4. OpenCode Configuration ─────────────────────────────────────────────
component_opencode() {
    section "4/8 — CONFIGURATION OPENCODE"

    if [ "$SUPRA_SKIP_OPENCODE" = "true" ]; then
        skip "OpenCode désactivé via SUPRA_SKIP_OPENCODE"
        return 0
    fi

    if ! tool_available opencode; then
        fail "OpenCode non installé"
        return 1
    fi

    local config_dir="${HOME}/.config/opencode"
    local config_file="${config_dir}/opencode.json"
    local supra_config="${SUPRA_ROOT}/opencode.json"

    mkdir -p "$config_dir"

    # Sauvegarder la config existante
    if [ -f "$config_file" ]; then
        backup_file "$config_file"
    fi

    # Détecter le meilleur modèle Ollama disponible
    local model=""
    if tool_available ollama; then
        model=$(ollama list 2>/dev/null | tail -n +2 | head -1 | awk '{print $1}')
    fi
    model="${model:-${SUPRA_DEFAULT_MODEL}}"

    # Déterminer si on utilise la config existante ou on en crée une
    if [ -f "$supra_config" ]; then
        info "Configuration SUPRA existante détectée : ${supra_config}"
        # Symlink si pas déjà fait
        if [ ! -L "$config_file" ] && [ ! -f "$config_file" ]; then
            ln -sf "$supra_config" "$config_file"
            pass "Lien symbolique : ${supra_config} → ${config_file}"
        elif [ -L "$config_file" ] && [ "$(readlink "$config_file")" = "$supra_config" ]; then
            pass "Lien symbolique déjà en place"
        else
            warn "Config existante dans ~/.config/opencode/, lien non créé"
        fi
    else
        info "Création de la configuration OpenCode SUPRA..."
        cat > "$config_file" <<CONFIG_EOF
{
  "\$schema": "https://opencode.ai/config.json",
  "instructions": ["AGENTS.md"],
  "default_agent": "build",
  "lsp": true,
  "provider": {
    "OLLAMA_LOCAL": {
      "npm": "@ai-sdk/openai-compatible",
      "options": {
        "baseURL": "http://127.0.0.1:${SUPRA_OLLAMA_PORT}/v1"
      },
      "models": {
        "${model}": {
          "name": "${model}"
        }
      }
    }
  },
  "model": "OLLAMA_LOCAL/${model}",
  "agent": {
    "SUPRA-Architect": {
      "mode": "subagent",
      "description": "Concevoir l'architecture du système, produire des ADR, valider la cohérence structurelle",
      "permission": { "edit": "deny", "bash": "deny" }
    },
    "SUPRA-Builder": {
      "mode": "subagent",
      "description": "Implémenter du code à partir de spécifications, générer des artefacts",
      "permission": { "edit": "allow", "bash": "allow" }
    },
    "SUPRA-Auditor": {
      "mode": "subagent",
      "description": "Analyse statique du code : conformité, sécurité, intégrité, cohérence",
      "permission": { "edit": "deny", "bash": "deny" }
    },
    "SUPRA-Reviewer": {
      "mode": "subagent",
      "description": "Relecture de code : style, conventions, performance, suggestions",
      "permission": { "edit": "deny", "bash": "deny" }
    },
    "SUPRA-Explorer": {
      "mode": "subagent",
      "description": "Navigation dans le codebase, recherche de fichiers, compréhension de structures",
      "permission": { "edit": "deny", "bash": "deny" }
    },
    "SUPRA-Research": {
      "mode": "subagent",
      "description": "Recherche d'information, documentation, investigation technique",
      "permission": { "edit": "deny", "bash": "deny" }
    },
    "SUPRA-Runtime": {
      "mode": "subagent",
      "description": "Analyse du comportement runtime, diagnostic de crashs, validation des flux",
      "permission": { "edit": "deny", "bash": "allow" }
    },
    "SUPRA-Refactor": {
      "mode": "subagent",
      "description": "Refactoring sécurisé sans altération fonctionnelle — READ ONLY",
      "permission": { "edit": "deny", "bash": "deny" }
    },
    "SUPRA-Router": {
      "mode": "subagent",
      "description": "Routage des missions vers le meilleur agent-modèle selon la tâche — READ ONLY",
      "permission": { "edit": "deny", "bash": "allow" }
    }
  },
  "command": {
    "supra-router": {
      "description": "Router une mission vers le meilleur agent et modèle SUPRA",
      "agent": "SUPRA-Router",
      "template": "\$ARGUMENTS"
    },
    "supra-audit": {
      "description": "Lancer un audit complet du code SUPRA",
      "agent": "SUPRA-Auditor",
      "template": "\$ARGUMENTS"
    },
    "supra-build": {
      "description": "Implémenter ou générer du code selon spécification",
      "agent": "SUPRA-Builder",
      "template": "\$ARGUMENTS"
    },
    "supra-review": {
      "description": "Lancer une relecture de code structurée",
      "agent": "SUPRA-Reviewer",
      "template": "\$ARGUMENTS"
    },
    "supra-runtime": {
      "description": "Analyser le comportement runtime et diagnostiquer les problèmes",
      "agent": "SUPRA-Runtime",
      "template": "\$ARGUMENTS"
    },
    "supra-search": {
      "description": "Rechercher du code, de la documentation ou des informations",
      "agent": "SUPRA-Explorer",
      "template": "\$ARGUMENTS"
    },
    "supra-status": {
      "description": "Afficher l'état complet du nœud SUPRA",
      "agent": "SUPRA-Router",
      "template": "\$ARGUMENTS"
    }
  },
  "references": {
    "agent-registry": {
      "path": "SUPRA_AGENT_REGISTRY_V1.md",
      "description": "Registre des agents SUPRA avec rôles et permissions"
    },
    "lab-architecture": {
      "path": "SUPRA_AI_LAB_ARCHITECTURE_V1.md",
      "description": "Architecture complète du laboratoire SUPRA AI LAB"
    },
    "model-registry": {
      "path": "SUPRA_MODEL_REGISTRY_V1.md",
      "description": "Registre des modèles LLM supportés"
    },
    "router-spec": {
      "path": "SUPRA_ROUTER_SPECIFICATION_V1.md",
      "description": "Spécification complète du routeur SUPRA"
    },
    "workflow": {
      "path": "SUPRA_WORKFLOW_V1.md",
      "description": "Pipeline et workflows du laboratoire SUPRA"
    }
  }
}
CONFIG_EOF
        if [ -f "$config_file" ]; then
            pass "Configuration OpenCode : ${config_file}"
        else
            fail "Échec de création de la configuration"
        fi
    fi
}

# ─── 5. Workspace Structure ────────────────────────────────────────────────
component_workspace() {
    section "5/8 — STRUCTURE DU WORKSPACE"

    local dirs=(
        "${SUPRA_ROOT}/Missions"
        "${SUPRA_ROOT}/Reports"
        "${SUPRA_ROOT}/Evidence"
        "${SUPRA_ROOT}/Logs"
        "${SUPRA_ROOT}/Freeze"
        "${SUPRA_ROOT}/Inbox"
        "${SUPRA_ROOT}/Outbox"
        "${SUPRA_ROOT}/Artifacts"
        "${SUPRA_ROOT}/_MISSIONS"
        "${SUPRA_ROOT}/_VERIFICATIONS"
        "${SUPRA_ROOT}/_NON_RUNTIME_ARCHITECTURE"
        "${SUPRA_ROOT}/SUPRA_RUNTIME/Inbox"
        "${SUPRA_ROOT}/SUPRA_RUNTIME/Outbox"
        "${SUPRA_ROOT}/SUPRA_RUNTIME/Running"
        "${SUPRA_ROOT}/SUPRA_RUNTIME/Done"
        "${SUPRA_ROOT}/SUPRA_RUNTIME/Blocked"
        "${SUPRA_ROOT}/SUPRA_RUNTIME/Logs"
        "${SUPRA_ROOT}/SUPRA_RUNTIME/Reports"
        "${SUPRA_ROOT}/.cannonico/missions"
        "${SUPRA_ROOT}/.cannonico/output"
    )

    for d in "${dirs[@]}"; do
        mkdir -p "$d"
    done

    # Write .gitkeep files in empty dirs
    find "$SUPRA_ROOT" -type d -empty -not -path '*/\.*' -not -path '*/_*' 2>/dev/null \
        | while read -r empty_dir; do
            touch "${empty_dir}/.gitkeep"
        done

    pass "Structure du workspace : ${SUPRA_ROOT}"
    info "$(find "$SUPRA_ROOT" -type d -not -path '*/\.*' -not -path '*/_SUPRA_BACKUPS/*' | wc -l | tr -d ' ') répertoires"
}

# ─── 6. Kernel Initialization ──────────────────────────────────────────────
component_kernel() {
    section "6/8 — INITIALISATION DU KERNEL"

    local kernel_root="${SUPRA_ROOT}/.kernel"

    # Créer la structure kernel si absente
    local kernel_dirs=(
        "${kernel_root}/contracts"
        "${kernel_root}/agents"
        "${kernel_root}/interfaces"
        "${kernel_root}/registry"
        "${kernel_root}/schemas"
        "${kernel_root}/memory"
        "${kernel_root}/graph"
        "${kernel_root}/events"
        "${kernel_root}/storage"
        "${kernel_root}/runtime"
        "${kernel_root}/providers"
        "${kernel_root}/plugins"
        "${kernel_root}/adapters"
        "${kernel_root}/modules"
        "${kernel_root}/models"
        "${kernel_root}/workspaces"
        "${kernel_root}/reports"
    )

    for d in "${kernel_dirs[@]}"; do
        mkdir -p "$d"
    done

    # Protocoles de base (identité du nœud)
    local protocols_file="${kernel_root}/contracts/protocols.list"
    if [ ! -s "$protocols_file" ]; then
        cat > "$protocols_file" <<PROTOCOLS_EOF
# SUPRA Kernel Protocols — V1
# Chaque ligne : <protocol_name> <version> <description>
supra.node.identity  1.0  Identité et configuration du nœud
supra.node.mission   1.0  Cycle de vie des missions
supra.node.memory    1.0  Stockage et indexation mémoire
supra.node.routing   1.0  Routage des missions vers agents/modèles
supra.node.execution 1.0  Exécution et orchestration des tâches
supra.node.audit     1.0  Audit et conformité
supra.node.benchmark 1.0  Benchmarking des modèles
supra.node.storage   1.0  Stockage persistant des artefacts
PROTOCOLS_EOF
        pass "Protocoles kernel : ${protocols_file}"
    else
        pass "Protocoles kernel existants : ${protocols_file}"
    fi

    # Identité du nœud
    local identity_file="${kernel_root}/runtime/node_identity.json"
    cat > "$identity_file" <<IDENTITY_EOF
{
  "node_id": "${SUPRA_NODE_ID}",
  "hostname": "$(hostname)",
  "platform": "$(detect_platform | cut -d'|' -f1)",
  "architecture": "$(detect_platform | cut -d'|' -f2)",
  "bootstrap_version": "${SCRIPT_VERSION}",
  "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "tools": {
    "bash": "$(bash --version | head -1 | tr -d '\n')",
    "git": "$(git --version 2>/dev/null | head -1 | tr -d '\n' || echo 'non installé')",
    "ollama": "$(ollama --version 2>/dev/null | head -1 | tr -d '\n' || echo 'non installé')",
    "opencode": "$(opencode --version 2>/dev/null | head -1 | tr -d '\n' || echo 'non installé')"
  },
  "status": "initialized"
}
IDENTITY_EOF
    pass "Identité du nœud : ${identity_file}"

    # Registre des agents locaux
    local agents_registry="${kernel_root}/registry/agents.json"
    if [ ! -f "$agents_registry" ]; then
        cat > "$agents_registry" <<AGENTS_EOF
{
  "agents": [
    { "id": "SUPRA-Architect", "role": "architecture", "status": "available" },
    { "id": "SUPRA-Builder",   "role": "implementation", "status": "available" },
    { "id": "SUPRA-Auditor",   "role": "analysis",     "status": "available" },
    { "id": "SUPRA-Reviewer",  "role": "review",       "status": "available" },
    { "id": "SUPRA-Explorer",  "role": "exploration",  "status": "available" },
    { "id": "SUPRA-Research",  "role": "research",     "status": "available" },
    { "id": "SUPRA-Runtime",   "role": "runtime",      "status": "available" },
    { "id": "SUPRA-Refactor",  "role": "refactoring",  "status": "available" },
    { "id": "SUPRA-Router",    "role": "routing",      "status": "available" }
  ],
  "updated_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
AGENTS_EOF
        pass "Registre des agents : ${agents_registry}"
    else
        pass "Registre des agents existant"
    fi

    pass "Kernel initialisé : ${kernel_root}"
}

# ─── 7. Startup & Recovery Scripts ─────────────────────────────────────────
component_scripts() {
    section "7/8 — SCRIPTS DE DÉMARRAGE & RÉCUPÉRATION"

    local scripts_dir="${SUPRA_ROOT}"

    if [ "$SUPRA_DRY_RUN" = "true" ]; then
        skip "Dry run : scripts non générés"
        return 0
    fi

    # ── GO_SUPRA.sh ────────────────────────────────────────────────────────
    local go_script="${scripts_dir}/GO_SUPRA.sh"
    if [ -f "$go_script" ]; then
        backup_file "$go_script"
    fi

    if [ -f "$go_script" ] && [ "$SUPRA_FORCE" != "true" ]; then
        pass "GO_SUPRA.sh existe déjà (utilisez SUPRA_FORCE=true pour écraser)"
    else
        cat > "$go_script" <<'GO_SCRIPT'
#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="${SUPRA_ROOT:-$(cd "$(dirname "$0")" && pwd)}"
NODE_ID="${SUPRA_NODE_ID:-supra-node-$(hostname | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9-')}"
MODEL="${SUPRA_DEFAULT_MODEL:-qwen3:4b}"

echo "╔══════════════════════════════════════════╗"
echo "║        SUPRA NODE — ${NODE_ID}           "
echo "╚══════════════════════════════════════════╝"

# 1. Vérifier/initialiser le workspace
if [ ! -d "${ROOT}/Missions" ]; then
    echo "[!] Workspace non initialisé — lancer SUPRA_BOOTSTRAP_V3.sh d'abord"
    exit 1
fi

# 2. Démarrer Ollama si nécessaire
if command -v ollama >/dev/null 2>&1; then
    if ! pgrep -x ollama >/dev/null 2>&1; then
        echo "[→] Démarrage Ollama..."
        ollama serve >/dev/null 2>&1 &
        sleep 3
    fi
    echo "[✓] Ollama : $(ollama --version 2>/dev/null || echo 'OK')"
else
    echo "[!] Ollama non installé"
fi

# 3. Vérifier OpenCode
if command -v opencode >/dev/null 2>&1; then
    echo "[✓] OpenCode : $(opencode --version 2>/dev/null || echo 'OK')"
else
    echo "[!] OpenCode non installé"
fi

# 4. Vérifier les modèles
if command -v ollama >/dev/null 2>&1; then
    MODELS=$(ollama list 2>/dev/null | tail -n +2 | wc -l | tr -d ' ')
    if [ "$MODELS" -gt 0 ]; then
        echo "[✓] ${MODELS} modèle(s) Ollama disponible(s)"
        ollama list 2>/dev/null | tail -n +2 | awk '{print "    - " $1}'
    else
        echo "[→] Téléchargement du modèle ${MODEL}..."
        ollama pull "$MODEL"
    fi
fi

# 5. État du nœud
echo
echo "╔══════════════════════════════════════════╗"
echo "║  NŒUD SUPRA PRÊT                         "
echo "║  Node ID : ${NODE_ID}"
echo "║  Root    : ${ROOT}"
echo "╚══════════════════════════════════════════╝"
echo
echo "Commandes :"
echo "  opencode run    → Lancer une mission interactive"
echo "  opencode edit   → Éditer avec l'IA"
echo "  supra-status    → État du nœud"
echo "  supra-audit     → Lancer un audit"
echo
GO_SCRIPT
        chmod +x "$go_script"
        pass "Script de démarrage : ${go_script}"
    fi

    # ── GO_SUPRA_RECOVERY.sh ──────────────────────────────────────────────
    local recovery_script="${scripts_dir}/GO_SUPRA_RECOVERY.sh"
    cat > "$recovery_script" <<'RECOVERY_SCRIPT'
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
RECOVERY_SCRIPT
    chmod +x "$recovery_script"
    pass "Script de récupération : ${recovery_script}"

    # ── SUPRA_NODE_STATUS.sh ──────────────────────────────────────────────
    local status_script="${scripts_dir}/SUPRA_NODE_STATUS.sh"
    cat > "$status_script" <<'STATUS_SCRIPT'
#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="${SUPRA_ROOT:-$(cd "$(dirname "$0")" && pwd)}"
NODE_ID="${SUPRA_NODE_ID:-supra-node-$(hostname | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9-')}"

echo "╔══════════════════════════════════════════╗"
echo "║  SUPRA NODE STATUS — ${NODE_ID}"
echo "╚══════════════════════════════════════════╝"
echo

# Node identity
if [ -f "${ROOT}/.kernel/runtime/node_identity.json" ]; then
    echo "[✓] Identité du nœud"
else
    echo "[!] Identité du nœud manquante"
fi

# Manifest
if [ -f "${ROOT}/.supra_node_manifest.json" ]; then
    local boot_version
    boot_version=$(grep -o '"bootstrap_version": "[^"]*"' "${ROOT}/.supra_node_manifest.json" | cut -d'"' -f4)
    echo "[✓] Manifest v${boot_version}"
fi

# Ollama
if command -v ollama >/dev/null 2>&1; then
    if pgrep -x ollama >/dev/null 2>&1; then
        local model_count
        model_count=$(ollama list 2>/dev/null | tail -n +2 | wc -l | tr -d ' ')
        echo "[✓] Ollama : ${model_count} modèle(s)"
    else
        echo "[!] Ollama : arrêté"
    fi
else
    echo "[!] Ollama : non installé"
fi

# OpenCode
if command -v opencode >/dev/null 2>&1; then
    echo "[✓] OpenCode : $(opencode --version 2>/dev/null || echo 'installé')"
else
    echo "[!] OpenCode : non installé"
fi

# Config
if [ -f "$HOME/.config/opencode/opencode.json" ]; then
    echo "[✓] Configuration OpenCode"
else
    echo "[!] Configuration OpenCode manquante"
fi

# Workspace
local dir_count
dir_count=$(find "$ROOT" -type d -not -path '*/\.*' -not -path '*/_SUPRA_BACKUPS/*' -not -path '*/node_modules/*' 2>/dev/null | wc -l | tr -d ' ')
echo "[✓] Workspace : ${dir_count} répertoires"

# Kernel
if [ -d "${ROOT}/.kernel" ]; then
    local kernel_dirs
    kernel_dirs=$(find "${ROOT}/.kernel" -type d | wc -l | tr -d ' ')
    echo "[✓] Kernel : ${kernel_dirs} répertoires"
else
    echo "[!] Kernel non initialisé"
fi

# Récents logs
if [ -d "${ROOT}/Logs" ]; then
    local log_count
    log_count=$(find "${ROOT}/Logs" -name 'bootstrap_*.log' | wc -l | tr -d ' ')
    echo "[✓] Logs : ${log_count} fichier(s)"
fi

echo
echo "╔══════════════════════════════════════════╗"
echo "║  Pour lancer SUPRA : ./GO_SUPRA.sh        "
echo "╚══════════════════════════════════════════╝"
STATUS_SCRIPT
    chmod +x "$status_script"
    pass "Script de statut : ${status_script}"

    # ── SUPRA_NODE_UNINSTALL.sh ───────────────────────────────────────────
    local uninstall_script="${scripts_dir}/SUPRA_NODE_UNINSTALL.sh"
    cat > "$uninstall_script" <<'UNINSTALL_SCRIPT'
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
UNINSTALL_SCRIPT
    chmod +x "$uninstall_script"
    pass "Script de désinstallation : ${uninstall_script}"
}

# ─── 8. Final Report ──────────────────────────────────────────────────────
component_report() {
    section "8/8 — RAPPORT FINAL"

    write_manifest
    write_status

    local duration
    duration=$(($(date +%s) - START_EPOCH))

    echo
    printf "  \033[1;37m═══════════════════════════════════════════════════════\033[0m\n"
    printf "  \033[1;37m  RÉSULTAT\033[0m\n"
    printf "  \033[1;37m═══════════════════════════════════════════════════════\033[0m\n"
    printf "  \033[32m  ✓ PASS : %d\033[0m\n" "$PASS"
    if [ "$FAIL" -gt 0 ]; then
        printf "  \033[31m  ✗ FAIL : %d\033[0m\n" "$FAIL"
    fi
    if [ "$WARN" -gt 0 ]; then
        printf "  \033[33m  ⚠ WARN : %d\033[0m\n" "$WARN"
    fi
    if [ "$SKIP" -gt 0 ]; then
        printf "  \033[90m  – SKIP : %d\033[0m\n" "$SKIP"
    fi
    printf "  \033[90m  Durée : %ds\033[0m\n" "$duration"
    echo
    printf "  \033[90m  Log     : %s\033[0m\n" "$LOG_FILE"
    printf "  \033[90m  Manifest: %s\033[0m\n" "$MANIFEST_FILE"
    printf "  \033[90m  Backup  : %s\033[0m\n" "$SUPRA_BACKUP_DIR"
    echo

    if [ "$FAIL" -eq 0 ]; then
        printf "  \033[1;32m  ✔ SUPRA NŒUD PRÊT\033[0m\n"
        printf "  \033[90m  Lancez : ./GO_SUPRA.sh\033[0m\n"
    else
        printf "  \033[1;31m  ✗ SUPRA NŒUD INCOMPLET — %d échec(s)\033[0m\n" "$FAIL"
        printf "  \033[90m  Consultez le log : %s\033[0m\n" "$LOG_FILE"
    fi
    echo
}

# ═══════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════

main() {
    printf "\033[1;36m"
    printf "╔══════════════════════════════════════════════════════════════╗\n"
    printf "║  %-60s  ║\n" "${SCRIPT_NAME} v${SCRIPT_VERSION}"
    printf "║  %-60s  ║\n" "Transforme n'importe quel ordinateur en nœud SUPRA."
    printf "║  %-60s  ║\n" "Node ID: ${SUPRA_NODE_ID}"
    printf "╚══════════════════════════════════════════════════════════════╝\n"
    printf "\033[0m"

    # Créer les répertoires de base
    mkdir -p "$(dirname "$LOG_FILE")"
    mkdir -p "$SUPRA_BACKUP_DIR"
    touch "$LOG_FILE"

    log "=== SUPRA BOOTSTRAP V${SCRIPT_VERSION} STARTED ==="
    log "Node ID: ${SUPRA_NODE_ID}"
    log "Platform: $(detect_platform)"
    log "Root: ${SUPRA_ROOT}"
    log "Backup: ${SUPRA_BACKUP_DIR}"

    # Exécuter les composants dans l'ordre
    component_platform
    component_prerequisites
    component_ollama
    component_opencode
    component_workspace
    component_kernel
    component_scripts
    component_report

    log "=== SUPRA BOOTSTRAP COMPLETED ==="

    if [ "$FAIL" -eq 0 ]; then
        return 0
    else
        return 1
    fi
}

main "$@"
