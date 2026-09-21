#!/usr/bin/env python3
from __future__ import annotations

import json
import re
import sys
from dataclasses import dataclass, asdict
from pathlib import Path
from typing import Callable

ROOT = Path(__file__).resolve().parents[1]

@dataclass
class Result:
    id: str
    category: str
    status: str
    detail: str

results: list[Result] = []

def add(i: str, category: str, status: str, detail: str):
    results.append(Result(i, category, status, detail))

def text(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")

def exists(path: str) -> bool:
    return (ROOT / path).exists()

def check(i: str, category: str, cond: bool, ok: str, bad: str, bad_status="BLOCKER"):
    add(i, category, "PASS" if cond else bad_status, ok if cond else bad)

# ---------------------------------------------------------------------------
# A. Canonical mission / manifest integrity
# ---------------------------------------------------------------------------
mission_md = "docs/MISSION_NOVA_ERA_EXECUTIVE_ORGANISM_V3_20260921.md"
mission_json = "docs/MISSION_NOVA_ERA_EXECUTIVE_ORGANISM_V3_20260921.json"
responsibility_json = "docs/CANONICAL_SURFACE_RESPONSIBILITY_V3.json"

check("A01", "V3_CANON", exists(mission_md), "V3 canonical mission document exists.", "Missing V3 canonical mission document.")
check("A02", "V3_CANON", exists(mission_json), "V3 executable manifest exists.", "Missing V3 executable manifest.")
check("A03", "V3_CANON", exists(responsibility_json), "Canonical surface responsibility registry exists.", "Missing surface responsibility registry.")

manifest = json.loads(text(mission_json))
registry = json.loads(text(responsibility_json))

check(
    "A04","V3_CANON",
    manifest.get("status") == "NEXT_GRANDE_MISSION_CANONICAL",
    "Manifest status is canonical next mission.",
    f"Unexpected manifest status: {manifest.get('status')}"
)
check(
    "A05","V3_CANON",
    manifest.get("execution_gate",{}).get("dependency") == "GRANDE_MISSION_TOTAL_IMAC_CANNONICO_ALONSO",
    "V3 is gated behind the current Grande Mission.",
    "V3 execution gate is not the current Grande Mission."
)
check(
    "A06","V3_CANON",
    manifest.get("invariant") == "ONE_RESPONSIBILITY_PER_CANONICAL_SURFACE",
    "Anti-duplication invariant is machine-readable.",
    "Anti-duplication invariant missing from manifest."
)

md = text(mission_md)
required_laws = [
    "ONE RESPONSIBILITY PER SURFACE",
    "BLOCKED_WITHOUT_DECISION_PACKET=PRODUCT_DEFECT",
    "NO_FAKE_PROGRESS",
    "NO_SILENT_PAYMENT",
    "NO_SILENT_LEGAL_SUBMISSION",
]
for idx, law in enumerate(required_laws, start=7):
    check(
        f"A{idx:02d}","V3_CANON",
        law in md,
        f"Mission law present: {law}",
        f"Mission law missing: {law}"
    )

# ---------------------------------------------------------------------------
# B. Surface ownership uniqueness
# ---------------------------------------------------------------------------
surfaces = registry.get("surfaces", [])
surface_names = [s.get("surface") for s in surfaces]
check(
    "B01","RESPONSIBILITY",
    len(surface_names) == len(set(surface_names)),
    "Every canonical surface name is unique.",
    "Duplicate canonical surface names detected."
)

owners: dict[str, list[str]] = {}
for surface in surfaces:
    for responsibility in surface.get("owns", []):
        owners.setdefault(responsibility, []).append(surface["surface"])

dups = {k:v for k,v in owners.items() if len(v)>1}
check(
    "B02","RESPONSIBILITY",
    not dups,
    "No exact responsibility is owned by more than one canonical surface.",
    f"Duplicated exact ownership: {dups}"
)

retire = registry.get("retire_or_fuse", [])
expected_merges = {
    "SUPRA Quick Action Decision Inbox":"Control",
    "SUPRA Quick Action Mission Center":"Missions",
    "SUPRA Quick Action Runtime Monitor":"Runtime",
    "SUPRA Quick Action SUPRA Chat":"Chat",
    "CAnnoNico internal Decision Inbox":"Control",
    "CAnnoNico internal Chat SUPRA":"Chat",
    "SUPRA standalone Executive Dashboard":"NOVA_ERA living organism + ojO private lens",
}
merge_map = {x["current"]:x["into"] for x in retire}
missing_merges = {k:v for k,v in expected_merges.items() if merge_map.get(k) != v}
check(
    "B03","RESPONSIBILITY",
    not missing_merges,
    "Critical duplicate surfaces have explicit canonical destinations.",
    f"Missing/incorrect fusion destinations: {missing_merges}"
)

# ---------------------------------------------------------------------------
# C. Human-gate state machine and inline decision UX
# ---------------------------------------------------------------------------
runner = text("SUPRA/SUPRAGrandeMissionRunner.swift")
gate = text("SUPRA/GrandeMissionHumanGateView.swift")
mission_detail = text("SUPRA/MissionDetailView.swift")

human_contract = [
    '!isAwaitingHumanDecision',
    'submitHumanDecision',
    'DECISION_QUESTION=',
    'OPTION_A=',
    'OPTION_B=',
    'OPTION_C=',
    'CONSEQUENCE_A=',
    'SAFE_DEFAULT=',
]
for idx, token in enumerate(human_contract, start=1):
    check(
        f"C{idx:02d}","HUMAN_GATE",
        token in runner,
        f"Runner human-gate contract contains {token}",
        f"Runner missing human-gate contract token {token}"
    )

ui_contract = [
    "Why blocked",
    "Choose",
    "Your answer",
    "Submit decision & resume",
    "Clarify / refresh options",
    "AWAITING NICOLAS",
]
for idx, token in enumerate(ui_contract, start=20):
    check(
        f"C{idx:02d}","HUMAN_GATE",
        token in gate,
        f"Inline human-gate UI contains {token}.",
        f"Inline human-gate UI missing {token}."
    )

check(
    "C30","HUMAN_GATE",
    "GrandeMissionHumanGateView()" in mission_detail and "mission.status == .blocked" in mission_detail,
    "Blocked mission detail embeds the inline Human Gate.",
    "Blocked mission detail does not embed the inline Human Gate."
)

# Synthetic state machine mirrors current code semantics.
def awaiting(receipt_time: int|None, decision_time: int|None, blocked=True):
    if not blocked or receipt_time is None:
        return False
    if decision_time is None:
        return True
    return decision_time <= receipt_time

state_cases = [
    ("blocked/no decision", awaiting(100,None), True),
    ("blocked/old decision", awaiting(100,90), True),
    ("blocked/new decision", awaiting(100,110), False),
    ("pass/no decision", awaiting(100,None,blocked=False), False),
]
for i,(name,got,expected) in enumerate(state_cases, start=40):
    check(f"C{i:02d}","HUMAN_GATE_SIM",got==expected,f"State machine PASS: {name}.",f"State machine failed: {name}.")

# ---------------------------------------------------------------------------
# D. Mission lifecycle simulation
# ---------------------------------------------------------------------------
phases = [f"P{i:02d}" for i in range(1,11)]

def simulate_lifecycle(block_at: int|None=None, decision_resolves=True):
    status = {p:"PENDING" for p in phases}
    for idx,p in enumerate(phases):
        if block_at is not None and idx == block_at:
            status[p] = "BLOCKED"
            if not decision_resolves:
                return status, "AWAITING_NICOLAS"
            status[p] = "PASS"
        else:
            status[p] = "PASS"
    return status, "COMPLETE"

s1, end1 = simulate_lifecycle()
check("D01","MISSION_SIM",end1=="COMPLETE" and all(v=="PASS" for v in s1.values()),"All-pass mission reaches COMPLETE.","All-pass mission failed to reach COMPLETE.")
s2, end2 = simulate_lifecycle(block_at=3,decision_resolves=False)
check("D02","MISSION_SIM",end2=="AWAITING_NICOLAS" and s2["P04"]=="BLOCKED","Blocked phase pauses at Nicolas.","Blocked phase did not pause correctly.")
s3, end3 = simulate_lifecycle(block_at=3,decision_resolves=True)
check("D03","MISSION_SIM",end3=="COMPLETE" and s3["P04"]=="PASS","Human decision can resume same phase and complete.","Resume-after-decision simulation failed.")

# ---------------------------------------------------------------------------
# E. Actionability / navigation contracts
# ---------------------------------------------------------------------------
org = text("SUPRA/OrganizationPeopleView.swift")
org_dossier = text("SUPRA/OrganizationDepartmentDossierView.swift")
ojo = text("SUPRA/OJOPrivateControlView.swift")
home = text("SUPRA/SUPRAOJOHomeView.swift")

check(
    "E01","ACTIONABILITY",
    "selectedDepartment = department" in org and "OrganizationDepartmentDossierView" in org,
    "Organization department cards open actionable dossiers.",
    "Organization departments are not navigable into dossiers."
)
for token in ["Missions","People / Roles","Decisions","Evidence","Actions","Query runtime","Find top bottleneck"]:
    check(
        "E_ORG_"+re.sub(r"\W+","_",token).upper(),
        "ACTIONABILITY",
        token in org_dossier,
        f"Organization dossier exposes {token}.",
        f"Organization dossier missing {token}."
    )
for token in ["Needs Nicolas","Machine can continue","Top bottleneck","What changed?","Next 3 moves"]:
    check(
        "E_OJO_"+re.sub(r"\W+","_",token).upper(),
        "ACTIONABILITY",
        token in ojo,
        f"ojO private control exposes {token}.",
        f"ojO private control missing {token}."
    )

# ---------------------------------------------------------------------------
# F. Runtime / momentum contract
# ---------------------------------------------------------------------------
runtime = text("SUPRA/SUPRAProcessObservatoryView.swift")
for token in [
    "ACCELERATING","PROGRESSING","STEADY","STALLED","BOTTLENECK","DEGRADING",
    "velocityPerMinute","accelerationPerMinute","windowDelta(seconds: 30)",
    "windowDelta(seconds: 120)","windowDelta(seconds: 600)","bottleneckAgeLabel"
]:
    check(
        "F_"+re.sub(r"\W+","_",token).upper(),
        "MOMENTUM",
        token in runtime,
        f"Runtime momentum contract contains {token}.",
        f"Runtime momentum contract missing {token}."
    )

# Synthetic momentum classification scenarios.
def momentum(bridge=True,bottlenecks=0,stagnation=0,drift_delta=0,mat_delta=0,closure_delta=0.0,vel=0.0,acc=0.0):
    if not bridge: return "OFFLINE"
    if bottlenecks>0 and stagnation>=120: return "BOTTLENECK"
    if drift_delta>0 and mat_delta==0 and closure_delta<=0: return "DEGRADING"
    if vel>0.01 and acc>0.10: return "ACCELERATING"
    if mat_delta>0 or closure_delta>0.002: return "PROGRESSING"
    if stagnation>=120: return "STALLED"
    return "STEADY"

momentum_cases=[
    ("offline",dict(bridge=False),"OFFLINE"),
    ("bottleneck",dict(bottlenecks=1,stagnation=180),"BOTTLENECK"),
    ("degrading",dict(drift_delta=2),"DEGRADING"),
    ("accelerating",dict(vel=1.2,acc=.3,mat_delta=1),"ACCELERATING"),
    ("progressing",dict(mat_delta=1),"PROGRESSING"),
    ("stalled",dict(stagnation=180),"STALLED"),
    ("steady",dict(),"STEADY"),
]
for i,(name,args,expected) in enumerate(momentum_cases,start=50):
    got=momentum(**args)
    check(f"F{i:02d}","MOMENTUM_SIM",got==expected,f"Momentum scenario {name} => {got}.",f"Momentum scenario {name}: expected {expected}, got {got}.")

# ---------------------------------------------------------------------------
# G. Sandbox / security guardrails
# ---------------------------------------------------------------------------
ent = text("SUPRA/SUPRA.entitlements")
check("G01","SECURITY","<key>com.apple.security.app-sandbox</key>" in ent and "<true/>" in ent,"App sandbox entitlement remains enabled.","App sandbox entitlement missing/disabled.")
check("G02","SECURITY","com.apple.security.network.client" in ent,"Outbound network entitlement explicitly present.","Network client entitlement missing.")
check("G03","SECURITY","com.apple.security.files.user-selected.read-only" in ent,"User-selected filesystem scope remains read-only.","Read-only user-selected file entitlement missing.")

# High-impact gates must remain in V3 mission.
for token in ["NO_SILENT_PAYMENT=YES","NO_SILENT_SIGNATURE=YES","NO_SILENT_LEGAL_SUBMISSION=YES","NO_SILENT_BANK_ACTION=YES"]:
    check(
        "G_"+re.sub(r"\W+","_",token),
        "SECURITY",
        token in md,
        f"Safety invariant present: {token}",
        f"Safety invariant missing: {token}"
    )

# Secret-literal heuristic: intentionally conservative.
secret_patterns = [
    re.compile(r"sk-[A-Za-z0-9_-]{20,}"),
    re.compile(r"Bearer\s+[A-Za-z0-9._-]{30,}"),
    re.compile(r"""pairing_token\s*[:=]\s*["'][^"']{20,}["']""", re.I),
]
suspects=[]
for path in (ROOT/"SUPRA").rglob("*"):
    if not path.is_file() or path.suffix not in {".swift",".json",".plist"}:
        continue
    body=path.read_text(encoding="utf-8",errors="ignore")
    for pat in secret_patterns:
        if pat.search(body):
            suspects.append(str(path.relative_to(ROOT)))
check("G20","SECURITY",not suspects,"No obvious hard-coded secret literal detected in SUPRA sources.",f"Potential hard-coded secret literal in: {sorted(set(suspects))}")

# ---------------------------------------------------------------------------
# H. Known gaps V3 is designed to remove (not candidate blockers)
# ---------------------------------------------------------------------------
content_view = text("SUPRA/ContentView.swift")
decision_store = text("SUPRA/DecisionStore.swift")
artifact_reader = text("SUPRA/ArtifactReader.swift")
connectors = text("SUPRA/ExternalConnectorModels.swift")
supra_dash = text("SUPRA/SupraControlCenterView.swift")

known_gap_checks = [
    ("H01","CANNONICO_APP_INSIDE_APP","case .cannonico:\n                    ContentView()" in home,
     "CAnnoNico still routes to legacy ContentView; V3 P5 must extract canonical-only surfaces."),
    ("H02","SUPRA_DUPLICATE_DASHBOARD","case .supra:\n                    SupraControlCenterView()" in home,
     "Standalone SUPRA dashboard still exists; V3 fuses it into NOVA ERA/ojO."),
    ("H03","DECISION_PROVIDER_EMPTY","decisions = []" in decision_store,
     "DecisionStore still has no real provider; V3 P4 must bind decisions."),
    ("H04","HISTORICAL_ARTIFACT_PATHS","SUPRA_EXECUTIVE_RUNTIME_V1" in artifact_reader or "_SYSTEM_BUILD" in artifact_reader,
     "Executive dashboard still reads historical hard-coded artifact paths."),
    ("H05","STATIC_CONNECTION_CATALOG","status: .connected" in connectors,
     "External connector catalog still embeds declared/static statuses instead of one live registry."),
]
for i,code,cond,detail in known_gap_checks:
    add(i,"KNOWN_GAP","KNOWN_GAP" if cond else "PASS",detail if cond else f"{code} not detected.")

# Monolith warnings
for path,limit in [("SUPRA/ContentView.swift",2500),("SUPRA/SUPRAProcessObservatoryView.swift",1400)]:
    n=len(text(path).splitlines())
    add(
        "H_MONOLITH_"+Path(path).stem.upper(),
        "KNOWN_GAP",
        "KNOWN_GAP" if n>limit else "PASS",
        f"{path}: {n} lines; progressive extraction recommended." if n>limit else f"{path}: {n} lines."
    )

# ---------------------------------------------------------------------------
# I. Build/runtime routing invariants
# ---------------------------------------------------------------------------
chat_adapter = text("SUPRA/SUPRAChatRuntimeAdapter.swift")
check("I01","RUNTIME","127.0.0.1:18765/health" in chat_adapter,"Chat runtime probes existing bridge health endpoint.","Primary bridge health probe missing.")
check("I02","RUNTIME","com.novaera.sol-github-bridge" in chat_adapter,"Chat runtime reuses existing bridge LaunchAgent.","Existing bridge kickstart identity missing.")
check("I03","RUNTIME","NO_NEW_BRIDGE=YES" in md and "NO_NEW_RUNTIME=YES" in md,"V3 forbids duplicate bridge/runtime creation.","V3 duplicate-runtime guardrail missing.")

# ---------------------------------------------------------------------------
# J. Report
# ---------------------------------------------------------------------------
blockers=[r for r in results if r.status=="BLOCKER"]
known=[r for r in results if r.status=="KNOWN_GAP"]
passes=[r for r in results if r.status=="PASS"]

verdict = "PREFLIGHT_PASS_WITH_KNOWN_GAPS" if not blockers else "PREFLIGHT_BLOCKED"

report={
    "schema":"SUPRA_V3_PREFLIGHT_SIMULATION_V1",
    "verdict":verdict,
    "counts":{"pass":len(passes),"known_gap":len(known),"blocker":len(blockers),"total":len(results)},
    "results":[asdict(r) for r in results],
}
outdir=Path(sys.argv[1]) if len(sys.argv)>1 else ROOT/"V3_PREFLIGHT_OUTPUT"
outdir.mkdir(parents=True,exist_ok=True)
(outdir/"V3_PREFLIGHT_REPORT.json").write_text(json.dumps(report,indent=2,ensure_ascii=False)+"\n",encoding="utf-8")

lines=[
    "# SUPRA V3 Preflight Simulation",
    "",
    f"**Verdict:** {verdict}",
    f"**PASS:** {len(passes)} · **KNOWN_GAP:** {len(known)} · **BLOCKER:** {len(blockers)} · **TOTAL:** {len(results)}",
    "",
    "## Blockers",
]
if blockers:
    lines += [f"- **{r.id}** [{r.category}] {r.detail}" for r in blockers]
else:
    lines += ["- None."]
lines += ["","## Known gaps (mission work, not candidate regressions)"]
if known:
    lines += [f"- **{r.id}** {r.detail}" for r in known]
else:
    lines += ["- None."]
lines += ["","## Passed contracts"]
lines += [f"- **{r.id}** [{r.category}] {r.detail}" for r in passes]
(outdir/"V3_PREFLIGHT_REPORT.md").write_text("\n".join(lines)+"\n",encoding="utf-8")

print(json.dumps(report["counts"],sort_keys=True))
print(verdict)
for r in blockers:
    print(f"BLOCKER {r.id} [{r.category}] {r.detail}")
for r in known:
    print(f"KNOWN_GAP {r.id} [{r.category}] {r.detail}")
sys.exit(1 if blockers else 0)
