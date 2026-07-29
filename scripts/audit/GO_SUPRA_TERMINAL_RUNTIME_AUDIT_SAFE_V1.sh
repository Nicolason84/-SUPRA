#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

STAMP="$(date '+%Y%m%d_%H%M%S')"
ROOT="$HOME/Desktop/SUPRA_TERMINAL_RUNTIME_AUDIT_SAFE_$STAMP"
mkdir -p "$ROOT"

REPORT="$ROOT/TERMINAL_RUNTIME_AUDIT.md"
PROCESS_TSV="$ROOT/ALL_TTY_PROCESSES.tsv"
TAB_TSV="$ROOT/TERMINAL_TAB_METADATA.tsv"

printf 'window\ttab\ttty\tbusy\tselected\ttitle\n' > "$TAB_TSV"

###############################################################################
# 1. Métadonnées Terminal seulement — jamais history/contents
###############################################################################

osascript - "$TAB_TSV" <<'APPLESCRIPT' || true
on run argv
    set outputPath to item 1 of argv

    tell application "Terminal"
        repeat with wi from 1 to count of windows
            set currentWindow to window wi

            try
                set selectedTTY to tty of selected tab of currentWindow as text
            on error
                set selectedTTY to ""
            end try

            repeat with ti from 1 to count of tabs of currentWindow
                set currentTab to tab ti of currentWindow

                try
                    set ttyValue to tty of currentTab as text
                on error
                    set ttyValue to ""
                end try

                try
                    set busyValue to busy of currentTab as text
                on error
                    set busyValue to "unknown"
                end try

                try
                    set titleValue to name of currentTab as text
                on error
                    set titleValue to "UNKNOWN"
                end try

                if ttyValue is selectedTTY and ttyValue is not "" then
                    set selectedValue to "true"
                else
                    set selectedValue to "false"
                end if

                set commandText to "/usr/bin/printf '%s\\t%s\\t%s\\t%s\\t%s\\t%s\\n' " & ¬
                    quoted form of (wi as text) & " " & ¬
                    quoted form of (ti as text) & " " & ¬
                    quoted form of ttyValue & " " & ¬
                    quoted form of busyValue & " " & ¬
                    quoted form of selectedValue & " " & ¬
                    quoted form of titleValue & " >> " & quoted form of outputPath

                do shell script commandText
            end repeat
        end repeat
    end tell
end run
APPLESCRIPT

###############################################################################
# 2. Tous les processus rattachés à des onglets/TTY
###############################################################################

ps -axo pid,ppid,pgid,state,%cpu,%mem,etime,tty,command |
awk '
BEGIN {
    OFS="\t"
    print "pid","ppid","pgid","state","cpu","mem","elapsed","tty","command"
}
NR > 1 && $8 ~ /^ttys[0-9]+$/ {
    command=""
    for (i=9; i<=NF; i++) {
        command=command (i==9 ? "" : " ") $i
    }
    print $1,$2,$3,$4,$5,$6,$7,$8,command
}
' > "$PROCESS_TSV"

###############################################################################
# 3. Contrôle précis de GO_SUPRA_EXPORT_ALL_TERMINAL_DATA_V1
###############################################################################

EXPORT_ROOT="$HOME/Desktop/SUPRA_TERMINAL_TOTAL_EXPORT_20260718_035157"
OUTPUT_INDEX="$EXPORT_ROOT/07_SUPRA_NOVA_OUTPUTS/EXPORTED_OUTPUTS.tsv"
EXPORT_LOG="$EXPORT_ROOT/09_REPORT/EXPORT.log"

snapshot() {
    local label="$1"

    echo "=== $label ==="
    date '+TIME=%Y-%m-%d %H:%M:%S'

    ps -axo pid,ppid,state,%cpu,%mem,etime,tty,command |
    grep '[G]O_SUPRA_EXPORT_ALL_TERMINAL_DATA_V1.sh' || true

    if [ -f "$OUTPUT_INDEX" ]; then
        printf 'OUTPUT_RECORDS='
        awk 'END {print NR-1}' "$OUTPUT_INDEX"

        printf 'OUTPUT_MTIME='
        stat -f '%Sm' -t '%Y-%m-%d %H:%M:%S' "$OUTPUT_INDEX"
    else
        echo "OUTPUT_INDEX=MISSING"
    fi

    if [ -f "$EXPORT_LOG" ]; then
        echo "LAST_LOG_LINES:"
        tail -n 12 "$EXPORT_LOG"
    fi
}

{
    snapshot "T0"
    sleep 15
    snapshot "T_PLUS_15S"
} > "$ROOT/EXPORT_PROGRESS_CHECK.txt"

###############################################################################
# 4. Verdict automatique
###############################################################################

python3 - \
"$TAB_TSV" \
"$PROCESS_TSV" \
"$ROOT/EXPORT_PROGRESS_CHECK.txt" \
"$REPORT" <<'PY'
import csv
import re
import sys
from pathlib import Path

tabs_path, process_path, progress_path, report_path = map(Path, sys.argv[1:])

def read_tsv(path):
    if not path.exists():
        return []
    with path.open(encoding="utf-8", errors="ignore") as handle:
        reader = csv.DictReader(handle, delimiter="\t")
        return list(reader) if reader.fieldnames else []

tabs = read_tsv(tabs_path)
processes = read_tsv(process_path)
progress = progress_path.read_text(encoding="utf-8", errors="ignore")

by_tty = {}
for process in processes:
    by_tty.setdefault(process.get("tty", ""), []).append(process)

records = [int(x) for x in re.findall(r"OUTPUT_RECORDS=(\d+)", progress)]
export_process_visible = "GO_SUPRA_EXPORT_ALL_TERMINAL_DATA_V1.sh" in progress

if len(records) >= 2 and records[-1] > records[-2]:
    export_state = "RUNNING_AND_PROGRESSING"
elif export_process_visible and len(records) >= 2 and records[-1] == records[-2]:
    export_state = "RUNNING_WITHOUT_OUTPUT_PROGRESS_REVIEW_REQUIRED"
elif export_process_visible:
    export_state = "RUNNING_STATUS_INCOMPLETE"
else:
    export_state = "PROCESS_NOT_RUNNING"

lines = [
    "# SUPRA Terminal Runtime Audit Safe V1",
    "",
    f"- Terminal tabs detected: **{len(tabs)}**",
    f"- TTY process records: **{len(processes)}**",
    f"- Terminal export state: **{export_state}**",
    "",
    "## Tabs and processes",
    "",
]

for tab in tabs:
    tty = tab.get("tty", "").replace("/dev/", "")
    attached = by_tty.get(tty, [])

    lines.extend([
        f"### Window {tab.get('window')} · Tab {tab.get('tab')}",
        "",
        f"- Title: `{tab.get('title', '')}`",
        f"- TTY: `{tty or 'UNKNOWN'}`",
        f"- Busy: `{tab.get('busy', '')}`",
        f"- Selected: `{tab.get('selected', '')}`",
        f"- Processes: **{len(attached)}**",
        "",
        "```text",
    ])

    if attached:
        for process in attached:
            lines.append(
                f"{process.get('pid')} "
                f"state={process.get('state')} "
                f"cpu={process.get('cpu')} "
                f"elapsed={process.get('elapsed')} "
                f"{process.get('command')}"
            )
    else:
        lines.append("NONE")

    lines.extend(["```", ""])

lines.extend([
    "## Export progress check",
    "",
    "```text",
    progress.rstrip(),
    "```",
])

report_path.write_text("\n".join(lines) + "\n", encoding="utf-8")

print(f"TABS_DETECTED={len(tabs)}")
print(f"TTY_PROCESS_RECORDS={len(processes)}")
print(f"TERMINAL_EXPORT_STATE={export_state}")
print(f"REPORT={report_path}")
PY

echo
echo "================ TERMINAL AUDIT ================"
cat "$REPORT"

echo
echo "================ REPORT PATH ================"
echo "$REPORT"
