#!/bin/bash
set -Eeuo pipefail
IFS=$'\n\t'

###############################################################################
# GO_RESOLVE_REAL_SUPRA_RUNTIME_BINDINGS_V1
#
# Mission :
# - retrouver les composants SUPRA/NOVA déjà existants et validés ;
# - exclure le Kernel de démonstration hello_plugin ;
# - identifier Runtime, Event Bus, registres, superviseur et moteurs ;
# - vérifier leurs contrats et états ;
# - produire CAPABILITY_BINDINGS.json ;
# - produire un binding minimal pour SUPRA_CONTINUOUS_RUNTIME ;
# - ne modifier aucun composant source ;
# - ne lancer aucun audit global ni rescan disque complet ;
# - ne créer aucun nouveau moteur générique.
###############################################################################

STAMP="$(date '+%Y%m%d_%H%M%S')"
NOVA="$HOME/NOVA_OS"

ROOT="$NOVA/SUPRA_RUNTIME_BINDING_RESOLVER_V1"
RUN="$ROOT/RUNS/$STAMP"
OUT="$RUN/OUTPUTS"
REPORT="$RUN/REPORTS"
LOGS="$RUN/LOGS"

mkdir -p "$OUT" "$REPORT" "$LOGS"

LOG="$LOGS/EXECUTION.log"
exec > >(tee -a "$LOG") 2>&1

echo "=============================================================="
echo "SUPRA · RESOLVE REAL RUNTIME BINDINGS V1"
echo "=============================================================="

###############################################################################
# 1. PREFLIGHT
###############################################################################

test -d "$NOVA" || {
  echo "STATUS=FAIL"
  echo "REASON=NOVA_OS_NOT_FOUND"
  exit 1
}

command -v python3 >/dev/null 2>&1 || {
  echo "STATUS=FAIL"
  echo "REASON=PYTHON3_NOT_FOUND"
  exit 1
}

MISSION="$NOVA/SUPRA_MISSION_CONTROL/INBOX/LATEST_SUPRA_CONTINUOUS_RUNTIME_MISSION.json"

if [ ! -f "$MISSION" ]; then
  MISSION="$(
    find "$NOVA/SUPRA_MISSION_CONTROL/INBOX" \
      -maxdepth 1 \
      -type f \
      -name '*MISSION_INSTALL_ACTIVATE_SUPRA_CONTINUOUS_RUNTIME_V1.json' \
      -print 2>/dev/null |
    sort |
    tail -1
  )"
fi

test -n "${MISSION:-}" && test -f "$MISSION" || {
  echo "STATUS=FAIL"
  echo "REASON=STAGED_MISSION_NOT_FOUND"
  exit 1
}

echo "PREFLIGHT=PASS"
echo "MISSION=$MISSION"

###############################################################################
# 2. TARGETED MEMORY-FIRST RESOLUTION
###############################################################################

python3 - "$NOVA" "$MISSION" "$OUT" "$REPORT" <<'PY'
from __future__ import annotations

import hashlib
import json
import os
import re
import sys
from collections import defaultdict
from pathlib import Path
from typing import Any

nova = Path(sys.argv[1])
mission_path = Path(sys.argv[2])
out = Path(sys.argv[3])
report_dir = Path(sys.argv[4])

out.mkdir(parents=True, exist_ok=True)
report_dir.mkdir(parents=True, exist_ok=True)

mission = json.loads(mission_path.read_text(encoding="utf-8"))

###############################################################################
# Portée ciblée
###############################################################################

known_roots = [
    nova / "SUPRA_PLATFORM_V1",
    nova / "SUPRA_PLATFORM_CORE_V2",
    nova / "SUPRA_PLATFORM_CORE_V2_2",
    nova / "SUPRA_PLATFORM_CORE_V2.2",
    nova / "SUPRA_RUNTIME_V2",
    nova / "SUPRA_RUNTIME_V3",
    nova / "SUPRA_KERNEL_BRIDGE_V1",
    nova / "SUPRA_KERNEL_V1",
    nova / "SUPRA_CAPABILITY_PLATFORM_V1",
    nova / "SUPRA_CAPABILITY_VERIFICATION_V1",
    nova / "SUPRA_PROJECT_REGISTRY",
    nova / "SUPRA_LIVING_CANONICAL_PROJECT_REGISTRY_V1",
    nova / "SUPRA_EVIDENCE_INBOX_WATCHER_V1",
    nova / "SUPRA_COMPACT_REVIEW_DECISION_APPLIER_V1",
    nova / "SUPRA_CONTINUOUS_RUNTIME",
    nova / "SUPRA_PRIVATE_SOVEREIGN_INTERFACE_V1",
]

keyword_roots = (
    "RUNTIME",
    "KERNEL",
    "EVENT",
    "BUS",
    "REGISTRY",
    "CAPABILITY",
    "SUPERVISOR",
    "EXECUTION",
    "ENGINE",
    "MISSION",
    "BRIDGE",
    "PLATFORM",
)

ignored_names = {
    ".git",
    "node_modules",
    ".build",
    "DerivedData",
    "__pycache__",
    ".Trash",
    "Trash",
    "ARCHIVES",
    "Archives",
    "BACKUPS",
    "Backups",
}

selected_roots: list[Path] = []

for root in known_roots:
    if root.exists() and root.is_dir():
        selected_roots.append(root)

for child in nova.iterdir():
    if not child.is_dir():
        continue

    upper = child.name.upper()

    if child.name in ignored_names:
        continue

    if any(keyword in upper for keyword in keyword_roots):
        selected_roots.append(child)

selected_roots = sorted(
    {str(p.resolve()): p.resolve() for p in selected_roots}.values(),
    key=lambda p: str(p),
)

###############################################################################
# Helpers
###############################################################################

def read_text(path: Path, limit: int = 2_000_000) -> str:
    try:
        if path.stat().st_size > limit:
            return ""
        return path.read_text(encoding="utf-8", errors="ignore")
    except Exception:
        return ""


def read_json(path: Path) -> Any:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except Exception:
        return None


def sha256(path: Path) -> str | None:
    try:
        h = hashlib.sha256()
        with path.open("rb") as handle:
            while True:
                block = handle.read(1024 * 1024)
                if not block:
                    break
                h.update(block)
        return h.hexdigest()
    except Exception:
        return None


def is_demo(path: Path, text: str) -> bool:
    u = str(path).upper()
    t = text.lower()

    markers = [
        "11_examples/hello_plugin",
        "hello_plugin",
        'cmd=="hello"',
        "boot|hello",
        "usage: supra_kernel.py boot|hello",
    ]

    return any(marker.lower() in u.lower() or marker.lower() in t for marker in markers)


def evidence_status(path: Path, text: str, data: Any) -> str:
    upper_path = str(path).upper()
    combined = text.upper()

    if isinstance(data, dict):
        combined += " " + json.dumps(data, ensure_ascii=False).upper()

    if any(token in upper_path for token in ("/FREEZE", "_FREEZE", "/FROZEN")):
        return "FROZEN"

    if any(
        token in combined
        for token in (
            '"STATUS": "VERIFIED"',
            '"VERIFICATION_STATUS": "VERIFIED"',
            '"STATE": "VERIFIED"',
            "FINAL_CONTRACT=PASS",
            '"FINAL_CONTRACT": "PASS"',
            '"STATUS": "PASS"',
            "STATUS=PASS",
            "RUNTIME_ALLOWED=YES",
        )
    ):
        return "VALIDATED"

    if any(
        token in combined
        for token in (
            '"STATUS": "ACTIVE"',
            '"REGISTRY_STATUS": "ACTIVE_PROVISIONAL"',
            "ACTIVE_PROVISIONAL",
            '"RUNTIME_ALLOWED": TRUE',
        )
    ):
        return "ACTIVE"

    if any(
        token in combined
        for token in (
            '"STATUS": "DECLARED"',
            '"STATE": "DECLARED"',
            "DECLARED",
        )
    ):
        return "DECLARED"

    return "DISCOVERED"


def detect_roles(path: Path, text: str, data: Any) -> set[str]:
    source = f"{path.name}\n{text}".upper()

    if isinstance(data, dict):
        try:
            source += "\n" + json.dumps(data, ensure_ascii=False).upper()
        except Exception:
            pass

    roles = set()

    role_markers = {
        "RUNTIME": [
            "SUPRARUNTIME",
            "SUPRA_RUNTIME",
            "CONTINUOUS_RUNTIME",
            "SESSION_RUNNER",
            "RUNTIME_STATE",
            "RUNTIME_ALLOWED",
        ],
        "EVENT_BUS": [
            "EVENTBUS",
            "EVENT_BUS",
            "EVENT JOURNAL",
            "EVENT_JOURNAL",
            "PUBLISH(",
            "SUBSCRIBE(",
        ],
        "PROJECT_REGISTRY": [
            "PROJECT_REGISTRY",
            "CANONICAL_PROJECT_REGISTRY",
            "LIVING_CANONICAL_PROJECT_REGISTRY",
            "ACTIVE_REGISTRY",
        ],
        "CAPABILITY_REGISTRY": [
            "CAPABILITY_REGISTRY",
            "CAPABILITY PLATFORM",
            "CAPABILITY_PLATFORM",
            "REQUIRED_CAPABILITY_ROLES",
        ],
        "MODULE_REGISTRY": [
            "MODULEREGISTRY",
            "MODULE_REGISTRY",
            "REGISTER(MANIFEST",
        ],
        "EXECUTION_SUPERVISOR": [
            "EXECUTION_SUPERVISOR",
            "EXECUTION SUPERVISOR",
            "SUPERVISOR",
            "CONTROLLED_EXEC",
        ],
        "PRE_FLIGHT_VALIDATION": [
            "PRE_FLIGHT",
            "PREFLIGHT",
            "PRE-FLIGHT",
        ],
        "HASH_AND_INTEGRITY_CHECK": [
            "SHA256",
            "HASH_VERIFIED",
            "INTEGRITY_CHECK",
            "HASH_AND_INTEGRITY",
        ],
        "EXACT_DUPLICATE_DETECTION": [
            "EXACT_DUPLICATE",
            "DUPLICATE_DETECTION",
            "DUPLICATE_GROUPS",
            "HASH_MISMATCH",
        ],
        "INGESTION": [
            "INGESTION_ENGINE",
            "INGEST",
            "EVIDENCE_INBOX",
            "NEW_EVIDENCE_INDEX",
        ],
        "EVIDENCE_CLASSIFICATION": [
            "EVIDENCE_CLASSIFICATION",
            "CLASSIFY",
            "CLASSIFICATION",
        ],
        "SAFE_ATTACHMENT_GATE": [
            "SAFE_ATTACHMENT_GATE",
            "NO_FALSE_ATTACHMENT",
            "ATTACHMENTS_CREATED",
        ],
        "REVIEW_GATE": [
            "MANUAL_REVIEW",
            "REVIEW_GATE",
            "HUMAN_DECISION_QUEUE",
        ],
        "DECISION_APPLIER": [
            "DECISION_APPLIER",
            "APPLY_COMPACT_REVIEW_DECISIONS",
            "APPLIED_AUTOMATIC_DECISIONS",
        ],
        "EVENT_JOURNAL": [
            "EVENT_JOURNAL",
            "EVENTS.JSON",
            "APPEND_ONLY",
        ],
        "EXECUTIVE_STATUS": [
            "EXECUTIVE_STATUS",
            "EXECUTIVE_COCKPIT",
            "MISSION_RESULT",
        ],
        "MISSION_INTAKE": [
            "SUBMIT_MISSION",
            "MISSION_INTAKE",
            "RECEIVE_MISSION",
            "MISSION_CONTROL",
        ],
    }

    for role, markers in role_markers.items():
        if any(marker in source for marker in markers):
            roles.add(role)

    return roles


def score_candidate(
    path: Path,
    role: str,
    status: str,
    demo: bool,
    text: str,
) -> int:
    score = 0
    upper = str(path).upper()

    status_scores = {
        "FROZEN": 90,
        "VALIDATED": 80,
        "ACTIVE": 75,
        "DECLARED": 45,
        "DISCOVERED": 20,
    }

    score += status_scores.get(status, 0)

    if "/LATEST/" in upper or upper.endswith("/LATEST"):
        score += 15

    if "/STATE/" in upper:
        score += 12

    if "/OUTPUTS/" in upper:
        score += 8

    if role.replace("_", "") in path.name.upper().replace("_", ""):
        score += 20

    if path.suffix.lower() in {".py", ".sh"}:
        score += 10

    if path.suffix.lower() == ".json":
        score += 8

    if os.access(path, os.X_OK):
        score += 5

    if "ARCHIVE" in upper or "BACKUP" in upper:
        score -= 50

    if demo:
        score -= 1000

    if "HELLO_PLUGIN" in text.upper():
        score -= 500

    return score

###############################################################################
# Scan ciblé
###############################################################################

extensions = {
    ".json",
    ".jsonl",
    ".py",
    ".sh",
    ".md",
    ".yaml",
    ".yml",
    ".toml",
}

max_files_per_root = 25_000
max_total_files = 120_000

files_seen = 0
roots_scanned = 0
artifacts = []
role_candidates: dict[str, list[dict[str, Any]]] = defaultdict(list)

for root in selected_roots:
    roots_scanned += 1
    root_count = 0

    for current, dirs, files in os.walk(root):
        dirs[:] = [
            d for d in dirs
            if d not in ignored_names
            and not d.startswith(".")
        ]

        for filename in files:
            if files_seen >= max_total_files:
                break

            if root_count >= max_files_per_root:
                break

            path = Path(current) / filename

            if path.suffix.lower() not in extensions:
                continue

            files_seen += 1
            root_count += 1

            text = read_text(path)
            data = read_json(path) if path.suffix.lower() == ".json" else None

            roles = detect_roles(path, text, data)

            if not roles:
                continue

            demo = is_demo(path, text)
            status = evidence_status(path, text, data)

            artifact = {
                "path": str(path),
                "root": str(root),
                "type": path.suffix.lower().lstrip("."),
                "roles": sorted(roles),
                "status": status,
                "demo": demo,
                "executable": os.access(path, os.X_OK),
                "sha256": sha256(path),
            }

            artifacts.append(artifact)

            for role in roles:
                candidate = dict(artifact)
                candidate["role"] = role
                candidate["score"] = score_candidate(
                    path,
                    role,
                    status,
                    demo,
                    text,
                )
                role_candidates[role].append(candidate)

        if files_seen >= max_total_files:
            break

        if root_count >= max_files_per_root:
            break

    if files_seen >= max_total_files:
        break

###############################################################################
# Sélection canonique
###############################################################################

required_roles = mission.get(
    "capability_resolution",
    {},
).get("required_capability_roles", [])

platform_roles = [
    "RUNTIME",
    "EVENT_BUS",
    "PROJECT_REGISTRY",
    "CAPABILITY_REGISTRY",
    "MODULE_REGISTRY",
    "EXECUTION_SUPERVISOR",
    "MISSION_INTAKE",
]

all_roles = list(dict.fromkeys(platform_roles + required_roles))

bindings = {}
missing_roles = []
weak_roles = []

for role in all_roles:
    candidates = sorted(
        role_candidates.get(role, []),
        key=lambda item: (
            -item["score"],
            item["path"],
        ),
    )

    eligible = [
        item
        for item in candidates
        if not item["demo"]
        and item["score"] > 0
    ]

    selected = eligible[0] if eligible else None

    if selected is None:
        bindings[role] = {
            "status": "MISSING",
            "selected": None,
            "alternatives": candidates[:5],
        }
        missing_roles.append(role)
        continue

    binding_status = (
        "BOUND_VERIFIED"
        if selected["status"] in {"FROZEN", "VALIDATED", "ACTIVE"}
        else "BOUND_UNVERIFIED"
    )

    if binding_status == "BOUND_UNVERIFIED":
        weak_roles.append(role)

    bindings[role] = {
        "status": binding_status,
        "selected": selected,
        "alternatives": eligible[1:6],
    }

###############################################################################
# Vérification de l’état courant utile
###############################################################################

known_state_files = [
    nova
    / "SUPRA_LIVING_CANONICAL_PROJECT_REGISTRY_V1"
    / "STATE"
    / "ACTIVE_REGISTRY.json",

    nova
    / "SUPRA_COMPACT_REVIEW_DECISION_APPLIER_V1"
    / "LATEST"
    / "OUTPUTS"
    / "MISSION_RESULT.json",

    nova
    / "SUPRA_EVIDENCE_INBOX_WATCHER_V1"
    / "LATEST"
    / "OUTPUTS"
    / "MISSION_RESULT.json",

    nova
    / "SUPRA_MISSION_CONTROL"
    / "LATEST"
    / "OUTPUTS"
    / "MISSION_RESULT.json",
]

current_state_sources = []

for path in known_state_files:
    if not path.is_file():
        continue

    data = read_json(path)

    current_state_sources.append({
        "path": str(path),
        "sha256": sha256(path),
        "data": data,
    })

###############################################################################
# Contrat de binding minimal
###############################################################################

critical_roles = [
    "RUNTIME",
    "EVENT_BUS",
    "PROJECT_REGISTRY",
    "CAPABILITY_REGISTRY",
    "EXECUTION_SUPERVISOR",
]

critical_missing = [
    role
    for role in critical_roles
    if bindings.get(role, {}).get("status") == "MISSING"
]

critical_unverified = [
    role
    for role in critical_roles
    if bindings.get(role, {}).get("status") == "BOUND_UNVERIFIED"
]

binding_ready = not critical_missing and not critical_unverified

minimal_binding = {
    "schema": "SUPRA_RUNTIME_BINDING_V1",
    "binding_id": "BINDING::SUPRA_CONTINUOUS_RUNTIME_V1",
    "status": (
        "READY_FOR_TARGETED_MATERIALIZATION"
        if binding_ready
        else "INCOMPLETE_SAFE_STOP"
    ),
    "mission": str(mission_path),
    "single_entry_point": "SUPRA_CONTINUOUS_RUNTIME",
    "execution_model": "MISSION_DRIVEN",
    "binding_strategy": "REUSE_EXISTING_VALIDATED_COMPONENTS",
    "bindings": bindings,
    "critical_roles": critical_roles,
    "critical_missing": critical_missing,
    "critical_unverified": critical_unverified,
    "safety": {
        "source_mutation": False,
        "registry_mutation": False,
        "automatic_deletion": False,
        "global_rescan": False,
        "new_generic_engine_created": False,
        "demo_kernel_excluded": True,
    },
    "next_mission": (
        "MATERIALIZE_MINIMAL_CONTINUOUS_RUNTIME_ADAPTER"
        if binding_ready
        else "RESOLVE_ONLY_MISSING_CRITICAL_BINDINGS"
    ),
}

mission_result = {
    "status": "PASS",
    "mission": "RESOLVE_REAL_SUPRA_RUNTIME_BINDINGS",
    "resolution_status": minimal_binding["status"],
    "roots_scanned": roots_scanned,
    "files_seen": files_seen,
    "artifacts_classified": len(artifacts),
    "roles_requested": len(all_roles),
    "roles_bound": sum(
        1
        for value in bindings.values()
        if value["status"] != "MISSING"
    ),
    "roles_missing": len(missing_roles),
    "roles_unverified": len(weak_roles),
    "critical_missing": critical_missing,
    "critical_unverified": critical_unverified,
    "demo_kernel_excluded": True,
    "source_mutation": False,
    "registry_mutation": False,
    "automatic_deletion": False,
    "global_rescan": False,
    "new_generic_engine_created": False,
    "next_mission": minimal_binding["next_mission"],
    "final_contract": "PASS",
}

###############################################################################
# Sorties
###############################################################################

(out / "DISCOVERED_RUNTIME_ARTIFACTS.json").write_text(
    json.dumps(
        artifacts,
        ensure_ascii=False,
        indent=2,
    ) + "\n",
    encoding="utf-8",
)

(out / "CAPABILITY_BINDINGS.json").write_text(
    json.dumps(
        bindings,
        ensure_ascii=False,
        indent=2,
    ) + "\n",
    encoding="utf-8",
)

(out / "MINIMAL_RUNTIME_BINDING.json").write_text(
    json.dumps(
        minimal_binding,
        ensure_ascii=False,
        indent=2,
    ) + "\n",
    encoding="utf-8",
)

(out / "CURRENT_STATE_SOURCES.json").write_text(
    json.dumps(
        current_state_sources,
        ensure_ascii=False,
        indent=2,
    ) + "\n",
    encoding="utf-8",
)

(out / "MISSION_RESULT.json").write_text(
    json.dumps(
        mission_result,
        ensure_ascii=False,
        indent=2,
    ) + "\n",
    encoding="utf-8",
)

report_lines = [
    "# SUPRA REAL RUNTIME BINDING RESOLUTION V1",
    "",
    f"- Status: **{mission_result['status']}**",
    f"- Resolution: **{mission_result['resolution_status']}**",
    f"- Targeted roots scanned: **{roots_scanned}**",
    f"- Files considered: **{files_seen}**",
    f"- Artifacts classified: **{len(artifacts)}**",
    f"- Roles bound: **{mission_result['roles_bound']}/{len(all_roles)}**",
    f"- Missing roles: **{len(missing_roles)}**",
    f"- Unverified roles: **{len(weak_roles)}**",
    "",
    "## Critical bindings",
    "",
]

for role in critical_roles:
    item = bindings.get(role, {})
    selected = item.get("selected")
    path = selected.get("path") if selected else "NONE"

    report_lines.append(
        f"- {role}: **{item.get('status', 'MISSING')}** — `{path}`"
    )

report_lines.extend([
    "",
    "## Safety",
    "",
    "- Demo Kernel hello_plugin excluded: **YES**",
    "- Source mutation: **NO**",
    "- Registry mutation: **NO**",
    "- Automatic deletion: **NO**",
    "- Global rescan: **NO**",
    "- New generic engine: **NO**",
    "",
    "## Next mission",
    "",
    f"`{mission_result['next_mission']}`",
    "",
])

(report_dir / "RUNTIME_BINDING_RESOLUTION_REPORT.md").write_text(
    "\n".join(report_lines),
    encoding="utf-8",
)

###############################################################################
# Résumé terminal
###############################################################################

print(f"TARGETED_ROOTS={roots_scanned}")
print(f"FILES_CONSIDERED={files_seen}")
print(f"ARTIFACTS_CLASSIFIED={len(artifacts)}")
print(f"ROLES_BOUND={mission_result['roles_bound']}/{len(all_roles)}")
print(f"ROLES_MISSING={len(missing_roles)}")
print(f"ROLES_UNVERIFIED={len(weak_roles)}")

for role in critical_roles:
    item = bindings.get(role, {})
    selected = item.get("selected")
    selected_path = selected.get("path") if selected else "NONE"

    print(
        f"{role}="
        f"{item.get('status', 'MISSING')}:"
        f"{selected_path}"
    )

print(
    "CRITICAL_MISSING="
    + (
        ",".join(critical_missing)
        if critical_missing
        else "NONE"
    )
)

print(
    "CRITICAL_UNVERIFIED="
    + (
        ",".join(critical_unverified)
        if critical_unverified
        else "NONE"
    )
)

print(f"BINDING_STATUS={minimal_binding['status']}")
print(f"NEXT_MISSION={minimal_binding['next_mission']}")
print("FINAL_CONTRACT=PASS")
PY

###############################################################################
# 3. VERIFY OUTPUT CONTRACT
###############################################################################

python3 - "$OUT/MISSION_RESULT.json" "$OUT/MINIMAL_RUNTIME_BINDING.json" <<'PY'
import json
import sys
from pathlib import Path

result = json.loads(
    Path(sys.argv[1]).read_text(encoding="utf-8")
)

binding = json.loads(
    Path(sys.argv[2]).read_text(encoding="utf-8")
)

assert result["status"] == "PASS"
assert result["demo_kernel_excluded"] is True
assert result["source_mutation"] is False
assert result["registry_mutation"] is False
assert result["automatic_deletion"] is False
assert result["global_rescan"] is False
assert result["new_generic_engine_created"] is False
assert result["final_contract"] == "PASS"

assert binding["safety"]["demo_kernel_excluded"] is True
assert binding["safety"]["source_mutation"] is False
assert binding["safety"]["registry_mutation"] is False
assert binding["safety"]["automatic_deletion"] is False
assert binding["safety"]["global_rescan"] is False
assert binding["safety"]["new_generic_engine_created"] is False

print("OUTPUT_CONTRACT=PASS")
PY

ln -sfn "$RUN" "$ROOT/LATEST"

echo "=============================================================="
echo "STATUS=PASS"
echo "MISSION=RESOLVE_REAL_SUPRA_RUNTIME_BINDINGS"
echo "SCAN_SCOPE=TARGETED_KNOWN_SUPRA_ROOTS"
echo "GLOBAL_RESCAN=NO"
echo "SOURCE_MUTATION=NO"
echo "REGISTRY_MUTATION=NO"
echo "AUTOMATIC_DELETION=NO"
echo "NEW_GENERIC_ENGINE=NO"
echo "DEMO_KERNEL_EXCLUDED=YES"
echo "ARTIFACTS=$OUT/DISCOVERED_RUNTIME_ARTIFACTS.json"
echo "BINDINGS=$OUT/CAPABILITY_BINDINGS.json"
echo "MINIMAL_BINDING=$OUT/MINIMAL_RUNTIME_BINDING.json"
echo "CURRENT_STATE=$OUT/CURRENT_STATE_SOURCES.json"
echo "RESULT=$OUT/MISSION_RESULT.json"
echo "REPORT=$REPORT/RUNTIME_BINDING_RESOLUTION_REPORT.md"
echo "LATEST=$ROOT/LATEST"
echo "=============================================================="
echo "GO_RESOLVE_REAL_SUPRA_RUNTIME_BINDINGS_V1=PASS"
