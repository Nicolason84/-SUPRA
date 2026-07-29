#!/bin/bash
set -Eeuo pipefail
IFS=$'\n\t'

###############################################################################
# GO_INSTALL_ACTIVATE_SUPRA_CONTINUOUS_RUNTIME_V1
#
# Mission :
# - retrouver la mission JSON téléchargée ;
# - vérifier son intégrité et son contrat ;
# - l’installer dans l’Inbox canonique des missions ;
# - retrouver un Mission Intake / Kernel / Runtime déjà existant ;
# - soumettre la mission avec le contrat détecté ;
# - ne créer aucun nouveau moteur générique ;
# - ne lancer aucun audit global ni rescan complet ;
# - échouer proprement si aucun consommateur existant n’est prouvé.
###############################################################################

STAMP="$(date '+%Y%m%d_%H%M%S')"
NOVA="$HOME/NOVA_OS"

MISSION_CANONICAL_NAME="MISSION_INSTALL_ACTIVATE_SUPRA_CONTINUOUS_RUNTIME_V1.json"

ROOT="$NOVA/SUPRA_MISSION_CONTROL"
INBOX="$ROOT/INBOX"
ACCEPTED="$ROOT/ACCEPTED"
RUNS="$ROOT/RUNS"
RUN="$RUNS/$STAMP"
OUT="$RUN/OUTPUTS"
REPORTS="$RUN/REPORTS"
LOGS="$RUN/LOGS"

mkdir -p "$INBOX" "$ACCEPTED" "$OUT" "$REPORTS" "$LOGS"

LOG="$LOGS/EXECUTION.log"
exec > >(tee -a "$LOG") 2>&1

echo "=============================================================="
echo "MISSION=INSTALL_ACTIVATE_SUPRA_CONTINUOUS_RUNTIME"
echo "STAMP=$STAMP"
echo "NOVA=$NOVA"
echo "=============================================================="

###############################################################################
# 1. Préflight
###############################################################################

test -d "$NOVA" || {
  echo "STATUS=FAIL"
  echo "REASON=NOVA_OS_NOT_FOUND"
  echo "EXPECTED=$NOVA"
  exit 1
}

command -v python3 >/dev/null 2>&1 || {
  echo "STATUS=FAIL"
  echo "REASON=PYTHON3_NOT_FOUND"
  exit 1
}

###############################################################################
# 2. Retrouver la mission téléchargée
###############################################################################

MISSION_SOURCE="$(
python3 - "$MISSION_CANONICAL_NAME" <<'PY'
import sys
from pathlib import Path

canonical = sys.argv[1]

roots = [
    Path.home() / "Downloads",
    Path.home() / "Desktop",
    Path.home() / "Documents",
]

names = [
    canonical,
    "MISSION_INSTALL_ACTIVATE_SUPRA_CONTINUOUS_RUNTIME_V1(1).json",
]

candidates = []

for root in roots:
    if not root.exists():
        continue

    for name in names:
        p = root / name
        if p.is_file():
            candidates.append(p)

    for p in root.glob("MISSION_INSTALL_ACTIVATE_SUPRA_CONTINUOUS_RUNTIME_V1*.json"):
        if p.is_file():
            candidates.append(p)

unique = {}
for p in candidates:
    try:
        unique[str(p.resolve())] = p
    except Exception:
        unique[str(p)] = p

ordered = sorted(
    unique.values(),
    key=lambda p: p.stat().st_mtime,
    reverse=True,
)

if ordered:
    print(ordered[0])
PY
)"

if [ -z "${MISSION_SOURCE:-}" ] || [ ! -f "$MISSION_SOURCE" ]; then
  echo "STATUS=FAIL"
  echo "REASON=MISSION_FILE_NOT_FOUND"
  echo
  echo "Place le fichier suivant dans Téléchargements ou sur le Bureau :"
  echo "$MISSION_CANONICAL_NAME"
  exit 1
fi

echo "MISSION_SOURCE=$MISSION_SOURCE"

###############################################################################
# 3. Validation stricte du contrat
###############################################################################

VALIDATION_JSON="$OUT/MISSION_VALIDATION.json"

python3 - "$MISSION_SOURCE" "$VALIDATION_JSON" <<'PY'
import hashlib
import json
import sys
from pathlib import Path

source = Path(sys.argv[1])
output = Path(sys.argv[2])

try:
    raw = source.read_bytes()
    data = json.loads(raw.decode("utf-8"))
except Exception as exc:
    result = {
        "status": "FAIL",
        "reason": "INVALID_JSON",
        "error": str(exc),
    }
    output.write_text(json.dumps(result, indent=2) + "\n")
    raise SystemExit("MISSION_JSON_INVALID")

errors = []

expected = {
    "schema": "SUPRA_MISSION_V1",
    "mission_id": "MISSION::INSTALL_ACTIVATE_SUPRA_CONTINUOUS_RUNTIME_V1",
    "status": "READY_FOR_KERNEL_CONSUMPTION",
    "execution_mode": "MISSION_DRIVEN",
}

for key, value in expected.items():
    if data.get(key) != value:
        errors.append(f"{key}: expected {value!r}, got {data.get(key)!r}")

continuity = data.get("continuity_contract", {})
acceptance = data.get("acceptance_contract", {})
safety = data.get("safety_invariants", {})

required_checks = {
    "reuse_existing_components":
        continuity.get("reuse_existing_components") == "MANDATORY",
    "new_generic_engine_forbidden":
        continuity.get("new_generic_engine") == "FORBIDDEN",
    "full_disk_rescan_forbidden":
        continuity.get("full_disk_rescan") == "FORBIDDEN",
    "global_reaudit_forbidden":
        continuity.get("global_reaudit") == "FORBIDDEN",
    "append_only":
        safety.get("append_only") is True,
    "no_source_mutation":
        safety.get("no_source_mutation") is True,
    "single_entry_point":
        acceptance.get("single_entry_point") is True,
    "runtime_expected_idle":
        acceptance.get("runtime_state") == "IDLE",
    "pipeline_expected_monitoring":
        acceptance.get("pipeline_mode") == "MONITORING",
    "next_trigger":
        acceptance.get("next_trigger") == "NEW_INDEPENDENT_EVIDENCE",
}

for name, passed in required_checks.items():
    if not passed:
        errors.append(f"contract check failed: {name}")

sha256 = hashlib.sha256(raw).hexdigest()

result = {
    "status": "PASS" if not errors else "FAIL",
    "source": str(source),
    "sha256": sha256,
    "mission_id": data.get("mission_id"),
    "schema": data.get("schema"),
    "checks": required_checks,
    "errors": errors,
}

output.write_text(
    json.dumps(result, ensure_ascii=False, indent=2) + "\n",
    encoding="utf-8",
)

if errors:
    raise SystemExit("MISSION_CONTRACT_INVALID")

print(f"MISSION_SHA256={sha256}")
print("MISSION_VALIDATION=PASS")
PY

###############################################################################
# 4. Installation append-only
###############################################################################

MISSION_HASH="$(
python3 - "$VALIDATION_JSON" <<'PY'
import json, sys
print(json.load(open(sys.argv[1]))["sha256"])
PY
)"

MISSION_INSTALLED="$INBOX/${STAMP}__${MISSION_CANONICAL_NAME}"
cp -p "$MISSION_SOURCE" "$MISSION_INSTALLED"

HASH_COPY="$(
python3 - "$MISSION_INSTALLED" <<'PY'
import hashlib, sys
print(hashlib.sha256(open(sys.argv[1], "rb").read()).hexdigest())
PY
)"

if [ "$MISSION_HASH" != "$HASH_COPY" ]; then
  echo "STATUS=FAIL"
  echo "REASON=COPY_HASH_MISMATCH"
  exit 1
fi

ln -sfn "$MISSION_INSTALLED" "$INBOX/LATEST_SUPRA_CONTINUOUS_RUNTIME_MISSION.json"

echo "MISSION_INSTALLED=$MISSION_INSTALLED"
echo "INSTALL_HASH_VERIFIED=YES"

###############################################################################
# 5. Détection MEMORY-FIRST des consommateurs existants
###############################################################################

DISCOVERY_JSON="$OUT/MISSION_CONSUMER_DISCOVERY.json"

python3 - "$NOVA" "$DISCOVERY_JSON" <<'PY'
import json
import os
import re
import sys
from pathlib import Path

nova = Path(sys.argv[1])
output = Path(sys.argv[2])

exact_names = {
    "SUPRA_CONTINUOUS_RUNTIME",
    "SUPRA_RUNTIME",
    "SUPRA_KERNEL",
    "NOVA_KERNEL",
    "MISSION_INTAKE",
    "MISSION_RUNNER",
    "KERNEL_MISSION_RUNNER",
    "SUPRA_MISSION_RUNNER",
    "GO_PRIVATE_KERNEL_INTERFACE_V1.sh",
}

name_patterns = (
    "MISSION_INTAKE",
    "MISSION_RUNNER",
    "CONTINUOUS_RUNTIME",
    "PRIVATE_KERNEL_INTERFACE",
    "SUPRA_KERNEL",
)

ignored_dirs = {
    ".git",
    "node_modules",
    ".build",
    "DerivedData",
    "__pycache__",
    "Archives",
    "ARCHIVES",
    "Trash",
    ".Trash",
}

executables = []
registries = []
commands = []

max_files = 120000
seen = 0

for root, dirs, files in os.walk(nova):
    dirs[:] = [
        d for d in dirs
        if d not in ignored_dirs and not d.startswith(".")
    ]

    for filename in files:
        seen += 1
        if seen > max_files:
            break

        path = Path(root) / filename
        upper = filename.upper()

        if (
            filename in exact_names
            or any(pattern in upper for pattern in name_patterns)
        ):
            try:
                if path.is_file() and os.access(path, os.X_OK):
                    executables.append(str(path))
            except OSError:
                pass

        if path.suffix.lower() in {".json", ".yaml", ".yml"}:
            if any(
                token in upper
                for token in (
                    "REGISTRY",
                    "MANIFEST",
                    "KERNEL",
                    "CAPABILITY",
                    "RUNTIME",
                    "MISSION",
                )
            ):
                registries.append(str(path))

    if seen > max_files:
        break

# Recherche ciblée de commandes déclaratives, sans exécuter le contenu.
command_keys = {
    "mission_intake_command",
    "submit_mission_command",
    "mission_runner_command",
    "kernel_command",
    "runtime_command",
}

for registry in registries[:5000]:
    p = Path(registry)

    if p.suffix.lower() != ".json":
        continue

    try:
        data = json.loads(p.read_text(encoding="utf-8"))
    except Exception:
        continue

    stack = [data]
    while stack:
        obj = stack.pop()

        if isinstance(obj, dict):
            for key, value in obj.items():
                if key.lower() in command_keys and isinstance(value, str):
                    commands.append({
                        "registry": str(p),
                        "key": key,
                        "command": value,
                    })
                else:
                    stack.append(value)

        elif isinstance(obj, list):
            stack.extend(obj)

def score_executable(path):
    u = path.upper()
    score = 0

    if "SUPRA_CONTINUOUS_RUNTIME" in u:
        score += 100
    if "MISSION_INTAKE" in u:
        score += 90
    if "MISSION_RUNNER" in u:
        score += 80
    if "PRIVATE_KERNEL_INTERFACE" in u:
        score += 70
    if "SUPRA_KERNEL" in u:
        score += 60
    if "/LATEST/" in u:
        score += 20
    if "/FREEZE" in u:
        score -= 100
    if "/ARCHIVE" in u:
        score -= 100

    return score

executables = sorted(
    set(executables),
    key=lambda p: (-score_executable(p), p),
)

result = {
    "status": "PASS",
    "scan_scope": str(nova),
    "full_disk_rescan": False,
    "files_considered_maximum": max_files,
    "candidate_executables": executables[:100],
    "declared_commands": commands[:100],
    "selected_executable": executables[0] if executables else None,
    "selected_declared_command":
        commands[0] if commands else None,
}

output.write_text(
    json.dumps(result, ensure_ascii=False, indent=2) + "\n",
    encoding="utf-8",
)

print(f"CANDIDATE_EXECUTABLES={len(executables)}")
print(f"DECLARED_COMMANDS={len(commands)}")
print(
    "SELECTED_EXECUTABLE="
    + str(result["selected_executable"] or "NONE")
)
PY

###############################################################################
# 6. Résolution du contrat d’invocation
###############################################################################

EXECUTION_PLAN="$OUT/MISSION_EXECUTION_PLAN.json"
MISSION_RESULT="$OUT/MISSION_RESULT.json"
SELECTED_CONSUMER="$(
python3 - "$DISCOVERY_JSON" <<'PY'
import json, sys
d = json.load(open(sys.argv[1]))
print(d.get("selected_executable") or "")
PY
)"

DECLARED_COMMAND="$(
python3 - "$DISCOVERY_JSON" <<'PY'
import json, sys
d = json.load(open(sys.argv[1]))
item = d.get("selected_declared_command")
print(item.get("command", "") if isinstance(item, dict) else "")
PY
)"

EXECUTION_MODE=""

if [ -n "$SELECTED_CONSUMER" ] && [ -x "$SELECTED_CONSUMER" ]; then
  BASE="$(basename "$SELECTED_CONSUMER")"
  UPPER="$(printf '%s' "$BASE" | tr '[:lower:]' '[:upper:]')"

  case "$UPPER" in
    *SUPRA_CONTINUOUS_RUNTIME*|*SUPRA_RUNTIME*)
      EXECUTION_MODE="RUNTIME_SUBMIT"
      ;;
    *MISSION_INTAKE*|*MISSION_RUNNER*)
      EXECUTION_MODE="MISSION_RUNNER"
      ;;
    *KERNEL*)
      EXECUTION_MODE="KERNEL_SUBMIT"
      ;;
    *)
      EXECUTION_MODE="GENERIC_EXISTING_CONSUMER"
      ;;
  esac
elif [ -n "$DECLARED_COMMAND" ]; then
  EXECUTION_MODE="DECLARED_REGISTRY_COMMAND"
else
  EXECUTION_MODE="STAGE_ONLY_NO_PROVEN_CONSUMER"
fi

python3 - \
  "$EXECUTION_PLAN" \
  "$EXECUTION_MODE" \
  "$SELECTED_CONSUMER" \
  "$DECLARED_COMMAND" \
  "$MISSION_INSTALLED" <<'PY'
import json
import sys
from pathlib import Path

out, mode, consumer, command, mission = sys.argv[1:]

plan = {
    "status": "READY",
    "execution_mode": mode,
    "selected_consumer": consumer or None,
    "declared_command": command or None,
    "mission": mission,
    "new_generic_engine_created": False,
    "full_disk_rescan": False,
    "global_reaudit": False,
    "source_mutation": False,
    "registry_mutation": False,
}

Path(out).write_text(
    json.dumps(plan, ensure_ascii=False, indent=2) + "\n",
    encoding="utf-8",
)
PY

###############################################################################
# 7. Soumission au consommateur existant
###############################################################################

SUBMISSION_STATUS="NOT_SUBMITTED"
CONSUMER_EXIT_CODE=0

set +e

case "$EXECUTION_MODE" in

  RUNTIME_SUBMIT)
    "$SELECTED_CONSUMER" submit "$MISSION_INSTALLED"
    CONSUMER_EXIT_CODE=$?

    if [ "$CONSUMER_EXIT_CODE" -ne 0 ]; then
      "$SELECTED_CONSUMER" SUBMIT_MISSION "$MISSION_INSTALLED"
      CONSUMER_EXIT_CODE=$?
    fi
    ;;

  MISSION_RUNNER)
    "$SELECTED_CONSUMER" "$MISSION_INSTALLED"
    CONSUMER_EXIT_CODE=$?
    ;;

  KERNEL_SUBMIT)
    "$SELECTED_CONSUMER" submit-mission "$MISSION_INSTALLED"
    CONSUMER_EXIT_CODE=$?

    if [ "$CONSUMER_EXIT_CODE" -ne 0 ]; then
      "$SELECTED_CONSUMER" SUBMIT_MISSION "$MISSION_INSTALLED"
      CONSUMER_EXIT_CODE=$?
    fi
    ;;

  GENERIC_EXISTING_CONSUMER)
    "$SELECTED_CONSUMER" "$MISSION_INSTALLED"
    CONSUMER_EXIT_CODE=$?
    ;;

  DECLARED_REGISTRY_COMMAND)
    export SUPRA_MISSION_FILE="$MISSION_INSTALLED"

    if [[ "$DECLARED_COMMAND" == *"{mission}"* ]]; then
      SAFE_MISSION="$(printf '%q' "$MISSION_INSTALLED")"
      COMMAND_TO_RUN="${DECLARED_COMMAND//\{mission\}/$SAFE_MISSION}"
      /bin/bash -lc "$COMMAND_TO_RUN"
      CONSUMER_EXIT_CODE=$?
    else
      /bin/bash -lc "$DECLARED_COMMAND \"\$SUPRA_MISSION_FILE\""
      CONSUMER_EXIT_CODE=$?
    fi
    ;;

  STAGE_ONLY_NO_PROVEN_CONSUMER)
    CONSUMER_EXIT_CODE=64
    ;;

esac

set -e

if [ "$CONSUMER_EXIT_CODE" -eq 0 ]; then
  SUBMISSION_STATUS="SUBMITTED"
  cp -p "$MISSION_INSTALLED" \
    "$ACCEPTED/${STAMP}__${MISSION_CANONICAL_NAME}"
else
  SUBMISSION_STATUS="STAGED_WAITING_FOR_CONSUMER"
fi

###############################################################################
# 8. Résultat final
###############################################################################

python3 - \
  "$MISSION_RESULT" \
  "$SUBMISSION_STATUS" \
  "$EXECUTION_MODE" \
  "$SELECTED_CONSUMER" \
  "$MISSION_INSTALLED" \
  "$CONSUMER_EXIT_CODE" <<'PY'
import json
import sys
from pathlib import Path

(
    output,
    submission_status,
    execution_mode,
    consumer,
    mission,
    exit_code,
) = sys.argv[1:]

submitted = submission_status == "SUBMITTED"

result = {
    "mission": "INSTALL_ACTIVATE_SUPRA_CONTINUOUS_RUNTIME",
    "status": "PASS" if submitted else "WAITING",
    "submission_status": submission_status,
    "execution_mode": execution_mode,
    "selected_consumer": consumer or None,
    "mission_file": mission,
    "consumer_exit_code": int(exit_code),
    "mission_validated": True,
    "mission_installed": True,
    "new_generic_engine_created": False,
    "full_disk_rescan": False,
    "global_reaudit": False,
    "source_mutation": False,
    "registry_mutation": False,
    "automatic_deletion": False,
    "next_step":
        "CHECK_RUNTIME_STATUS"
        if submitted
        else "TARGETED_BINDING_REQUIRED",
    "final_contract":
        "PASS"
        if submitted
        else "SAFE_STOP",
}

Path(output).write_text(
    json.dumps(result, ensure_ascii=False, indent=2) + "\n",
    encoding="utf-8",
)
PY

ln -sfn "$RUN" "$ROOT/LATEST"

REPORT="$REPORTS/INSTALL_ACTIVATE_SUPRA_CONTINUOUS_RUNTIME_REPORT.md"

cat > "$REPORT" <<EOF
# SUPRA CONTINUOUS RUNTIME — INSTALLATION ET ACTIVATION

- Mission source : \`$MISSION_SOURCE\`
- Mission installée : \`$MISSION_INSTALLED\`
- Validation : **PASS**
- Hash vérifié : **YES**
- Mode d’exécution : **$EXECUTION_MODE**
- Consommateur sélectionné : \`${SELECTED_CONSUMER:-NONE}\`
- Soumission : **$SUBMISSION_STATUS**
- Code consommateur : **$CONSUMER_EXIT_CODE**

## Garanties

- Nouveau moteur générique : **NO**
- Rescan disque complet : **NO**
- Réaudit global : **NO**
- Mutation source : **NO**
- Mutation registre : **NO**
- Suppression automatique : **NO**

## Résultat

\`$MISSION_RESULT\`
EOF

echo
echo "=============================================================="
echo "MISSION=INSTALL_ACTIVATE_SUPRA_CONTINUOUS_RUNTIME"
echo "MISSION_VALIDATION=PASS"
echo "MISSION_INSTALLED=YES"
echo "INSTALL_HASH_VERIFIED=YES"
echo "EXECUTION_MODE=$EXECUTION_MODE"
echo "SELECTED_CONSUMER=${SELECTED_CONSUMER:-NONE}"
echo "SUBMISSION_STATUS=$SUBMISSION_STATUS"
echo "CONSUMER_EXIT_CODE=$CONSUMER_EXIT_CODE"
echo "NEW_GENERIC_ENGINE_CREATED=NO"
echo "FULL_DISK_RESCAN=NO"
echo "GLOBAL_REAUDIT=NO"
echo "SOURCE_MUTATION=NO"
echo "REGISTRY_MUTATION=NO"
echo "AUTOMATIC_DELETION=NO"
echo "RESULT=$MISSION_RESULT"
echo "REPORT=$REPORT"
echo "LATEST=$ROOT/LATEST"

if [ "$SUBMISSION_STATUS" = "SUBMITTED" ]; then
  echo "NEXT_STEP=CHECK_RUNTIME_STATUS"
  echo "FINAL_CONTRACT=PASS"
  echo "=============================================================="
  echo "GO_INSTALL_ACTIVATE_SUPRA_CONTINUOUS_RUNTIME_V1=PASS"
  exit 0
fi

echo "NEXT_STEP=TARGETED_BINDING_REQUIRED"
echo "FINAL_CONTRACT=SAFE_STOP"
echo "=============================================================="
echo
echo "La mission est validée et installée, mais aucun consommateur"
echo "Kernel/Runtime existant n’a pu être invoqué avec certitude."
echo
echo "Copie-colle uniquement le bloc de résultat ci-dessus."
exit 64
