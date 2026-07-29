#!/bin/bash
set -Eeuo pipefail
IFS=$'\n\t'
umask 077

STAMP="$(date '+%Y%m%d_%H%M%S')"
NOVA="${NOVA:-$HOME/NOVA_OS}"
ROOT="$NOVA/SUPRA_KERNEL_V1"
STATE="$ROOT/STATE"
CURRENT="$ROOT/CURRENT"
SCRIPTS="$ROOT/SCRIPTS"
LOGS="$ROOT/LOGS"
BRIDGE="$ROOT/BRIDGE"
RUN="$ROOT/RUNS/V1_1_$STAMP"
PORT="${SUPRA_BRIDGE_PORT:-8899}"

mkdir -p "$STATE" "$CURRENT" "$SCRIPTS" "$LOGS" "$BRIDGE" "$RUN"
LOG="$LOGS/KERNEL_V1_1_$STAMP.log"
exec > >(tee -a "$LOG") 2>&1

die(){ echo "ERROR=$*" >&2; exit 1; }

[ -f "$STATE/kernel_state.json" ] || die "KERNEL_STATE_NOT_FOUND"
command -v python3 >/dev/null 2>&1 || die "PYTHON3_NOT_FOUND"

cat > "$SCRIPTS/kernel_v1_1_runtime.py" <<'PY'
#!/usr/bin/env python3
from __future__ import annotations
import json, os, re, subprocess, time
from http.server import ThreadingHTTPServer, BaseHTTPRequestHandler
from pathlib import Path
from urllib.parse import urlparse

ROOT = Path(os.environ["SUPRA_KERNEL_ROOT"])
STATE = ROOT / "STATE"
BRIDGE = ROOT / "BRIDGE"
SOURCE = STATE / "kernel_state.json"
LIVE = STATE / "kernel_live.json"
CLASSIFIED = STATE / "classified_registry.json"

HEAVY_PATTERNS = {
    "knowledge_compiler": r"supra_knowledge_compiler",
    "puchero": r"puchero_v2\.py",
    "cannonico": r"cannonico",
    "nexus": r"nexus",
    "cleanroom": r"cleanroom",
    "video_swap": r"SupraVideoSwap|supra_video_swap",
}

def dump(path: Path, obj):
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix(path.suffix + ".tmp")
    tmp.write_text(json.dumps(obj, ensure_ascii=False, indent=2, sort_keys=True), encoding="utf-8")
    tmp.replace(path)

def load(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))

def proc_rows():
    try:
        out = subprocess.check_output(
            ["ps","-axo","pid=,ppid=,etime=,%cpu=,%mem=,state=,command="],
            text=True, stderr=subprocess.DEVNULL
        )
        return out.splitlines()
    except Exception:
        return []

def live_processes():
    rows = proc_rows()
    result = {}
    for name, pat in HEAVY_PATTERNS.items():
        found = []
        rx = re.compile(pat, re.I)
        for row in rows:
            if rx.search(row) and "kernel_v1_1_runtime.py" not in row:
                parts = row.strip().split(None, 6)
                if len(parts) == 7:
                    found.append({
                        "pid": int(parts[0]),
                        "ppid": int(parts[1]),
                        "etime": parts[2],
                        "cpu": float(parts[3]),
                        "mem": float(parts[4]),
                        "state": parts[5],
                        "command": parts[6],
                    })
        result[name] = found
    return result

def classify(item):
    name = (item.get("name") or "").lower()
    path = (item.get("path") or "").lower()
    caps = set(item.get("capabilities") or [])
    scripts = item.get("scripts") or []
    manifests = item.get("manifests") or []
    text = " ".join([name, path])

    if any(x in text for x in ["/archive","/archives","_archive","_old","/backup","_backup"]):
        return "ARCHIVE"
    if any(x in text for x in ["freeze","frozen"]):
        return "FREEZE"
    if any(x in text for x in ["doc","book","constitution","readme","manual"]) and not scripts:
        return "DOCUMENTATION"
    if any(x in text for x in ["experiment","sandbox","lab","prototype","poc"]):
        return "EXPERIMENT"
    if any(x in text for x in ["app","ios","android","swiftui","xcodeproj"]) and ("bridge.render" in caps or manifests):
        return "APP"
    if scripts and caps:
        return "WORKER"
    if manifests or scripts:
        return "LIBRARY"
    return "PROJECT"

def build_classification(kernel):
    workers = kernel.get("workers", {}).get("workers", [])
    classified = []
    counts = {}
    real_workers = []
    for item in workers:
        typ = classify(item)
        row = dict(item)
        row["entity_type"] = typ
        row["worker_eligible"] = typ == "WORKER"
        classified.append(row)
        counts[typ] = counts.get(typ, 0) + 1
        if typ == "WORKER":
            real_workers.append(row)
    result = {
        "generated_at": time.time(),
        "counts": counts,
        "entities": classified,
        "real_workers": real_workers,
        "real_worker_count": len(real_workers),
    }
    dump(CLASSIFIED, result)
    return result

def build_live(kernel, classified):
    processes = live_processes()
    active = sum(len(v) for v in processes.values())
    heavy_running = [k for k,v in processes.items() if v]
    capabilities = kernel.get("capabilities", {}).get("capabilities", [])
    fusion = kernel.get("fusion_candidates", [])
    return {
        "status": "READY",
        "updated_at": time.time(),
        "kernel_version": "1.1",
        "counts": {
            "projects": kernel.get("audit", {}).get("projects", 0),
            "entities": len(classified["entities"]),
            "real_workers": classified["real_worker_count"],
            "capabilities": len(capabilities),
            "fusion_candidates": len(fusion),
            "active_processes": active,
        },
        "classification": classified["counts"],
        "processes": processes,
        "heavy_running": heavy_running,
        "policy": {
            "kernel_only_launches_workers": True,
            "single_heavy_io_worker": True,
            "observatory_read_only": True,
            "source_mutation": False,
            "freeze_mutation": False,
        },
        "recommendation": "WAIT" if len(heavy_running) > 1 else ("RUNNING" if heavy_running else "READY"),
    }

def html():
    return """<!doctype html>
<html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>SUPRA BRIDGE</title>
<style>
body{font-family:-apple-system,BlinkMacSystemFont,sans-serif;background:#0b1020;color:#eef2ff;margin:0}
main{max-width:1200px;margin:auto;padding:28px}
h1{margin:0}.sub{opacity:.65;margin-bottom:20px}
.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(190px,1fr));gap:14px}
.card{background:#151c31;border:1px solid #2b3554;border-radius:16px;padding:18px}
.big{font-size:30px;font-weight:750}.ok{color:#7ee787}.warn{color:#f2cc60}
pre{white-space:pre-wrap;max-height:420px;overflow:auto;background:#080c17;padding:14px;border-radius:12px}
small{opacity:.6}
</style></head>
<body><main>
<h1>SUPRA BRIDGE</h1>
<div class="sub">Kernel V1.1 · classified registry · live runtime</div>
<div class="grid">
<div class="card"><div>Kernel</div><div id="kernel" class="big ok">...</div></div>
<div class="card"><div>Projects</div><div id="projects" class="big">0</div></div>
<div class="card"><div>Real workers</div><div id="workers" class="big">0</div></div>
<div class="card"><div>Capabilities</div><div id="caps" class="big">0</div></div>
<div class="card"><div>Active processes</div><div id="procs" class="big">0</div></div>
<div class="card"><div>Recommendation</div><div id="rec" class="big">...</div></div>
</div>
<br>
<div class="grid">
<div class="card"><h3>Classification</h3><pre id="classify"></pre></div>
<div class="card"><h3>Runtime live</h3><pre id="runtime"></pre></div>
<div class="card"><h3>Policy</h3><pre id="policy"></pre></div>
</div>
<br><small id="updated"></small>
<script>
async function refresh(){
  const r=await fetch('/api/status',{cache:'no-store'});
  const s=await r.json();
  document.getElementById('kernel').textContent=s.status;
  document.getElementById('projects').textContent=s.counts.projects;
  document.getElementById('workers').textContent=s.counts.real_workers;
  document.getElementById('caps').textContent=s.counts.capabilities;
  document.getElementById('procs').textContent=s.counts.active_processes;
  document.getElementById('rec').textContent=s.recommendation;
  document.getElementById('classify').textContent=JSON.stringify(s.classification,null,2);
  document.getElementById('runtime').textContent=JSON.stringify(s.processes,null,2);
  document.getElementById('policy').textContent=JSON.stringify(s.policy,null,2);
  document.getElementById('updated').textContent='Updated: '+new Date(s.updated_at*1000).toLocaleString();
}
refresh(); setInterval(refresh,3000);
</script></main></body></html>"""

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        p = urlparse(self.path).path
        if p == "/api/status":
            body = LIVE.read_bytes() if LIVE.exists() else b'{"status":"BOOTING"}'
            self.send_response(200)
            self.send_header("Content-Type","application/json; charset=utf-8")
            self.send_header("Cache-Control","no-store")
            self.end_headers()
            self.wfile.write(body)
            return
        if p in ("/","/index.html"):
            body = html().encode()
            self.send_response(200)
            self.send_header("Content-Type","text/html; charset=utf-8")
            self.end_headers()
            self.wfile.write(body)
            return
        self.send_response(404); self.end_headers()

def main():
    kernel = load(SOURCE)
    classified = build_classification(kernel)
    dump(LIVE, build_live(kernel, classified))

    import threading
    def loop():
        while True:
            try:
                dump(LIVE, build_live(kernel, classified))
            except Exception:
                pass
            time.sleep(3)
    threading.Thread(target=loop, daemon=True).start()

    port = int(os.environ.get("SUPRA_BRIDGE_PORT","8899"))
    print(f"SUPRA_KERNEL_V1_1=READY")
    print(f"REAL_WORKERS={classified['real_worker_count']}")
    print(f"BRIDGE=http://127.0.0.1:{port}")
    ThreadingHTTPServer(("127.0.0.1",port), Handler).serve_forever()

if __name__ == "__main__":
    main()
PY

chmod +x "$SCRIPTS/kernel_v1_1_runtime.py"
python3 -m py_compile "$SCRIPTS/kernel_v1_1_runtime.py"
echo "PY_COMPILE=PASS"

if [ -f "$STATE/kernel_v1_1.pid" ]; then
  OLD_PID="$(cat "$STATE/kernel_v1_1.pid" 2>/dev/null || true)"
  [ -n "$OLD_PID" ] && kill "$OLD_PID" 2>/dev/null || true
fi

for PID in $(lsof -ti tcp:"$PORT" 2>/dev/null || true); do
  kill "$PID" 2>/dev/null || true
done

SUPRA_KERNEL_ROOT="$ROOT" SUPRA_BRIDGE_PORT="$PORT" \
nohup python3 "$SCRIPTS/kernel_v1_1_runtime.py" \
>"$LOGS/runtime_v1_1_$STAMP.log" 2>&1 &

PID=$!
echo "$PID" > "$STATE/kernel_v1_1.pid"
sleep 3

kill -0 "$PID" 2>/dev/null || die "RUNTIME_FAILED_TO_START"

curl -fsS "http://127.0.0.1:$PORT/api/status" > "$RUN/STATUS.json"

cp "$RUN/STATUS.json" "$CURRENT/STATUS_V1_1.json"
printf '%s\n' "$RUN" > "$CURRENT/RUN_PATH_V1_1.txt"

open "http://127.0.0.1:$PORT"

echo "KERNEL_V1_1=PASS"
echo "PID=$PID"
echo "BRIDGE=http://127.0.0.1:$PORT"
echo "STATUS=$RUN/STATUS.json"
