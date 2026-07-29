#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="/Users/nicolasalonso/Desktop/NOVA_OS/SUPRA/SUPRA"

CONTENT="$ROOT/ContentView.swift"

[ -f "$CONTENT" ] || {
    echo "ContentView.swift introuvable"
    exit 1
}

OUT="$ROOT/_EXTRACTION_PLAN"
mkdir -p "$OUT"

python3 <<'PY'
import pathlib
import re

root = pathlib.Path("/Users/nicolasalonso/Desktop/NOVA_OS/SUPRA/SUPRA")
content = (root/"ContentView.swift").read_text(encoding="utf-8")

out = root/"_EXTRACTION_PLAN"

store_dir = out/"Store"
models_dir = out/"Models"
core_dir = out/"Core"

(store_dir).mkdir(parents=True, exist_ok=True)
(models_dir).mkdir(parents=True, exist_ok=True)
(core_dir/"Megabus").mkdir(parents=True, exist_ok=True)
(core_dir/"Evidence").mkdir(parents=True, exist_ok=True)
(core_dir/"Integrity").mkdir(parents=True, exist_ok=True)

# ----------- blocs BEGIN / END -----------

blocks = [
(
"SUPRA_TERMINAL_MEGABUS_BRIDGE_V1_BEGIN",
"SUPRA_TERMINAL_MEGABUS_BRIDGE_V1_END",
core_dir/"Megabus"/"SUPRATerminalMegabusBridge.swift"
),
(
"SUPRA_MISSION_EVIDENCE_LOADER_V1_BEGIN",
"SUPRA_MISSION_EVIDENCE_LOADER_V1_END",
core_dir/"Evidence"/"SUPRAMissionEvidenceLoader.swift"
),
(
"SUPRA_SYSTEM_INTEGRITY_V1_BEGIN",
"SUPRA_SYSTEM_INTEGRITY_V1_END",
core_dir/"Integrity"/"SUPRASystemIntegrityLoader.swift"
),
]

for begin,end,dest in blocks:
    p=re.compile(
        rf"// {begin}(.*?)// {end}",
        re.S
    )
    m=p.search(content)
    if m:
        dest.write_text(
            "import Foundation\nimport SwiftUI\n\n"+m.group(1).strip()+"\n",
            encoding="utf-8"
        )

# ----------- extraction types -----------

targets = {
"SUPRAExecutiveStore":store_dir/"SUPRAExecutiveStore.swift",
"SUPRAExecutiveModel":models_dir/"SUPRAExecutiveModel.swift",
"SUPRASystem":models_dir/"SUPRASystem.swift",
"SUPRAMetrics":models_dir/"SUPRAMetrics.swift",
"SUPRASection":models_dir/"SUPRASection.swift",
"SUPRARecord":models_dir/"SUPRARecord.swift",
"SUPRASource":models_dir/"SUPRASource.swift",
"SUPRAAlert":models_dir/"SUPRAAlert.swift",
}

for typename,dest in targets.items():

    p=re.compile(
        rf"(final\s+class|struct|enum)\s+{typename}\b.*?(?=\n(?:final\s+class|struct|enum)\s+[A-Za-z_]|$)",
        re.S
    )

    m=p.search(content)

    if m:
        dest.write_text(
            "import Foundation\nimport SwiftUI\n\n"+m.group(0).strip()+"\n",
            encoding="utf-8"
        )

report=[]

for f in sorted(out.rglob("*.swift")):
    report.append(str(f.relative_to(out)))

(out/"EXTRACTION_REPORT.txt").write_text(
    "\n".join(report),
    encoding="utf-8"
)

print()
print("====================================")
print("PLAN D'EXTRACTION GÉNÉRÉ")
print(out)
print("====================================")
PY

open "$OUT"
